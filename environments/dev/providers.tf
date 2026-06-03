# The random and local providers need no configuration — they generate values
# and write local files without any credentials or endpoints. They are declared
# here so the intent is explicit at the root.
provider "random" {}

provider "local" {}
