---
title: 'Why are you using insecure settings?'
weight: 5
---

Every now and then, you might spot a `--insecure` (or equivalent settings)
in the commands.

It is unfortunate, but sometimes it is necessary. With the availability of
[Let's Encrypt](https://letsencrypt.org), it would actually be rather simple
to add proper TLS certificates. But when you are running a local `minikube`
instance, you can't properly use certificates. Also does the process of getting
a proper Let's Encrypt certificate still need a significant effort and understanding,
on the user side, especially when requesting a wildcard certificate.

You are encouraged to try with a proper certificate though, and drop the `--insecure`
for commands.
