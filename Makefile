SOURCE := M17 Internet Interface.md
PDF    := M17 Internet Interface.pdf

VERSION := $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//' || echo draft)

.PHONY: pdf clean

pdf:
	pandoc "$(SOURCE)" \
		--metadata-file=metadata.yaml \
		--metadata=date:"$$(date +%Y-%m-%d)" \
		--metadata=version:"$(VERSION)" \
		--template=template.typ \
		--shift-heading-level-by=-1 \
		--pdf-engine=typst \
		--from=markdown+smart \
		-o "$(PDF)"

clean:
	rm -f "$(PDF)"
