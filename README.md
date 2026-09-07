# M17_inet

[M17](https://m17foundation.org/) is a modern open source digital radio protocol built by hams, for hams. This repository contains the specification of the M17 Internet interface, while the air interface is specified in https://github.com/M17-Project/M17_spec. It is still a work in progress, meaning that this repository is meant to be updated now and then.

## Building the PDF

The specification is authored in Markdown ([M17 Internet Interface.md](M17%20Internet%20Interface.md)) and rendered to PDF with [Pandoc](https://pandoc.org/) using [Typst](https://typst.app/) as the PDF engine.

To build locally on macOS:

```sh
brew install pandoc typst
make pdf
```

On other platforms, install pandoc (3.x or later) and typst, then run `make pdf`.

A GitHub Actions workflow also builds the PDF on every push and pull request (available as a workflow artifact) and attaches it to tagged (`v*`) releases.
