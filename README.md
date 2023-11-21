<div align="center">
  <img src="https://download.next-hat.com/ressources/images/logo.png" >
  <h1>Nanocl Get Started</h1>
</div>

<blockquote class="tags">
 <strong>Tags</strong>
 </br>
 <span id="nxtmdoc-meta-keywords">
  documentation, guide, getting started
 </span>
</blockquote>

</br>
</br>

## Official Nanocl get started

Image used for [Nanocl][nanocl] get started [tutorial][get-started].</br>
That just return headers and environnement variables for all incomming requests.

Example:

Create a new [Statefile][statefile] `get_started.yml` :

```yaml
Kind: Deployment
ApiVersion: v0.11

Namespace: global

# See all options:
# https://docs.next-hat.com/references/nanocl/resource
Resources:
- Name: get-started.com
  Kind: ProxyRule
  Version: v0.8
  Data:
    Rules:
    - Domain: get-started.com
      Network: Internal
      Locations:
      - Path: /
        Target:
          Key: get-started.global.c
          Port: 9000

# See all options:
# https://docs.next-hat.com/references/nanocl/cargo
Cargoes:
- Name: get-started
  Container:
    Image: ghcr.io/nxthat/nanocl-get-started:latest
    Env:
    - APP=GET_STARTED
```

Execute the [Statefile][statefile] :

```sh
nanocl state apply -s get_started.yml
```

[nanocl]: https://next-hat.com/nanocl
[get-started]: https://docs.next-hat.com/guides/nanocl/get-started/orientation-and-setup
[statefile]: https://docs.next-hat.com/references/nanocl/statefile
