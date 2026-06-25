First, you will need to have Nix package manager installed. If you
have permissions to write to `/nix` path on your filesystem, this can
be done using the [official
instruction](https://nixos.org/download.html):

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

However, often this may not be posible when working on an university
or a lab cluster, where some other way is needed, which is outside of
the scope of this tutorial.
