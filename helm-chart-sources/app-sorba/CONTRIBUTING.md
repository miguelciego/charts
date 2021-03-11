## Contributing


## Developer Certificate of Origin + License


## Code of conduct



## Merge request guidelines



### Working with the tests

The tests are written in [Go](https://golang.org) (version 1.13 or later,
with [modules enabled](https://golang.org/cmd/go/#hdr-Module_support)) using
the [Terratest](https://github.com/gruntwork-io/terratest) library. To work
on the tests, you need to have [Helm 2](https://v2.helm.sh/docs/) and
[Go](https://golang.org) installed.

To run the tests, run the following commands from the root of your copy of `auto-deploy-app`:

```shell
helm repo add stable https://charts.helm.sh/stable # required only once
helm dependency build .               # required any time the dependencies change
cd test
GO111MODULE=auto go test .            # required for every change to the tests or the template
```
