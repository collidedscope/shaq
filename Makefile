shaq: shaq.cr
	crystal build --release --no-debug shaq.cr

dev: shaq.cr
	crystal build shaq.cr
