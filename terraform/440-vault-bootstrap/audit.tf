# Every request, hashed where sensitive, to the pod's stdout and from there to Cloud Logging.
resource "vault_audit" "stdout" {
  type = "file"
  path = "stdout"

  options = {
    file_path = "stdout"
  }
}
