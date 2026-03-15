let
  # Users:
  joe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyNdEOw7tfOHWCM0w2A7UzspnYYpNiF+nak51dcx3d7 joe@ivo";

  # Machines:
  odin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILtN0oGnLZsbvVUTSsH+AnU4V++Uad9v3gFSbG58S3zZ odin";

in
{
  "user-password.age".publicKeys = [ joe odin ];
  "ci-password.age".publicKeys = [ joe odin ];
  "knot-tsig-key.age".publicKeys = [ joe odin ];
  "acme-tsig-key.age".publicKeys = [ joe odin ];
}
