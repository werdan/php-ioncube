@test "Check if ionCube Loader is loaded" {
  php -m | grep -E '^ionCube Loader'
}
