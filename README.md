# M17_inet

[M17](https://m17foundation.org/) is a modern open source digital radio protocol built by hams, for hams.

## Purpose

This part of the specification is where M17 over-the-air engineering is translated to Internet Protocol (IP) capabilities that M17 users want. In the spirit of true Open-Source innovation, M17 developers are encouraged to document their M17 contributions here so that their M17 programs and tools can be used by other developers and the entire M17 ecosystem can be used and enjoyed by all M17 users.

## Where to get involved

1. Casual discussion or simple questions on any M17 Specification related topic from anyone can be started on the #m17-specification channel of the  [M17 Discord](https://discord.com/).
1. More serious discussion that warrants a permanent record should take place by either raising an issue on [this repo](https://github.com/M17-Project/M17_inet), or posting a message to the [M17-Users groups.io](https://groups.io/g/M17-Users/topics) website.
1. Developers can submit a pull request (PR) to [this repo](https://github.com/M17-Project/M17_inet) to add information about their M17 application(s). They only need to supply the information in a new `##` Chapter in the `M17 Internet Interface.md` file. If they want to make sure the PDF is rendered properly, see the next section.
1. Even M17 users who aren't developers can submit a PR if they already have an account on github.com and see a problem with either specification document and know how to fix it. Many have done so already.



## Building the PDF

The specification is authored in Markdown ([M17 Internet Interface.md](M17%20Internet%20Interface.md)) and rendered to PDF with [Pandoc](https://pandoc.org/) using [Typst](https://typst.app/) as the PDF engine.

To build locally on macOS:

```sh
brew install pandoc typst
make pdf
```

On other platforms, install pandoc (3.x or later) and typst, then run `make pdf`. Look around, On Ubuntu 26.04 panddoc is only available from *apt* and typst is only available on *snap*.

A GitHub Actions workflow also builds the PDF on every push and pull request (available as a workflow artifact) and attaches it to tagged (`v*`) releases.
