#!/usr/bin/env python3

## Reasons of this wrapper:
## 1) Byond in a bad relationship with unicode (513?)
## 2) Byond export proc does not support https (someday?)

import requests, argparse, json, os, sys

def read_arguments():
	parser = argparse.ArgumentParser(
		description="get wrapper"
	)

	parser.add_argument(
		"url",
	)

	parser.add_argument(
		"--json", type=os.fsencode
	)

	return parser.parse_args()

def main(options):

	if(options.json):
		options.json = json.loads(byond_outer_text(options.json))

	try:

		if(options.json):
			r = requests.get(options.url, json=options.json)
		else:
			r = requests.get(options.url)

		r.raise_for_status()

	except requests.exceptions.RequestException as e:
		print(e, file=sys.stderr)
		sys.exit(1)

	sys.stdout.buffer.write(byond_inner_text(r.text))

def byond_outer_text(text):
	return text.decode("utf-8")

def byond_inner_text(text):
	return text.encode("utf-8")

if __name__ == "__main__":
	options = read_arguments()
	sys.exit(main(options))
