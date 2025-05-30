defmodule Algora.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Algora.{Repo}
  alias Hex.API.User
  alias Algora.Repo
  alias Algora.Accounts.{User, Identity, Entity}

  schema "users" do
    field :email, :string
    field :name, :string
    field :handle, :string
    field :channel_tagline, :string
    field :avatar_url, :string
    field :external_homepage_url, :string
    field :twitter_url, :string
    field :videos_count, :integer
    field :is_live, :boolean, default: false
    field :stream_key, :string
    field :visibility, Ecto.Enum, values: [public: 1, unlisted: 2]
    field :bounties_count, :integer
    field :solving_challenge, :boolean, default: false
    field :featured, :boolean, default: false
    field :tags, {:array, :string}, default: []

    embeds_many :tech, Tech do
      field :name, :string
      field :pct, :float
      field :color, :string
    end

    embeds_many :orgs_contributed, Org do
      field :handle, :string
      field :avatar_url, :string
    end

    has_many :identities, Identity
    has_one :entity, Entity

    timestamps()
  end

  def get_visibility(info) do
    # HACK: temporary heuristic to prevent abuse
    with %{"followers" => followers, "created_at" => created_at} <- info,
         {:ok, registered_at, _} <- DateTime.from_iso8601(created_at),
         true <- DateTime.diff(DateTime.utc_now(), registered_at, :second) > 30 * 24 * 60 * 60,
         true <- followers >= 20 do
      :public
    else
      _ -> :unlisted
    end
  end

  def create_or_update_youtube_identity(user, auth) do
    attrs = %{
      provider: to_string(auth.provider),
      provider_id: auth.uid,
      provider_email: auth.info.email,
      provider_meta: auth.info,
      provider_login: auth.info.email,
      provider_token: auth.credentials.token,
      provider_refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at
    }

    case Repo.get_by(Identity, user_id: user.id, provider: "google") do
      nil -> %Identity{user_id: user.id}
      identity -> identity
    end
    |> Identity.changeset(attrs)
    |> Repo.insert_or_update()
    |> case do
      {:ok, identity} -> {:ok, identity}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_youtube_identity(user) do
   case Repo.get_by(Identity, user_id: user.id, provider: "google") do
     nil -> {:error, :not_found}
     identity -> Repo.delete(identity)
   end
  end

  @doc """
  A user changeset for github registration.
  """
  def github_registration_changeset(info, primary_email, emails, token) do
    %{"login" => handle, "avatar_url" => avatar_url, "html_url" => external_homepage_url} = info

    identity_changeset =
      Identity.github_registration_changeset(info, primary_email, emails, token)

    if identity_changeset.valid? do
      params = %{
        "handle" => handle,
        "email" => primary_email,
        "name" => get_change(identity_changeset, :provider_name),
        "avatar_url" => avatar_url,
        "external_homepage_url" => external_homepage_url,
        "visibility" => get_visibility(info)
      }

      %User{}
      |> cast(params, [:email, :name, :handle, :avatar_url, :external_homepage_url, :visibility])
      |> validate_required([:email, :name, :handle, :visibility])
      |> validate_handle()
      |> validate_email()
      |> put_assoc(:identities, [identity_changeset])
    else
      %User{}
      |> change()
      |> Map.put(:valid?, false)
      |> put_assoc(:identities, [identity_changeset])
    end
  end

  def update_user_tags(user, tags) do
    user
    |> User.settings_changeset(%{tags: tags})
    |> Repo.update()
  end

  def settings_changeset(%User{} = user, params) do
    user
    |> cast(params, [:handle, :name, :channel_tagline, :tags])
    |> validate_required([:handle, :name, :channel_tagline])
    |> validate_handle()
    |> validate_length(:tags, max: 10)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp validate_handle(changeset) do
    changeset
    |> validate_format(:handle, ~r/^[a-zA-Z0-9_-]{2,32}$/)
    |> unique_constraint(:handle)
    |> prepare_changes(fn changeset ->
      case fetch_change(changeset, :channel_tagline) do
        {:ok, _} ->
          changeset

        :error ->
          handle = get_field(changeset, :handle)
          put_change(changeset, :channel_tagline, "#{handle}'s channel")
      end
    end)
  end
end
