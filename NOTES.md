# build an elixir runtime
nanobox build

# create a development environment
nanobox dev deploy

# console into the dev env
nanobox dev console

# install phoenix
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# generate the project and copy it in
cd /tmp
mix phoenix.new myapp --no-brunch --no-ecto
cp -a /tmp/myapp/* /app
cd -

# add inotify as dependency


# update port to 8080
config/dev.exs
config/prod.exs

# fetch deps
mix deps.get

# run phoenix
mix phoenix.server

Repo.insert(User.registration_changeset(%User{}, %{
              email: "mino@wlm.de", 
              username: "mino", 
              password: "secret123"
            }))


docker run -it --rm -p 8080:8080 -e PORT=8080 -e HOST=<domain-name> -e DB_HOST=<postgresql-domain> -e DB_NAME=hi_docker -e DB_USER=<postgresql-user> -e DB_PASSWORD=<postgresql-password> -e SECRET_KEY_BASE=<top-secret> hi_docker:release foreground