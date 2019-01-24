#!/usr/bin/env python3

import requests, argparse, os, sys

def read_arguments():
	parser = argparse.ArgumentParser(
		description="get page"
	)

	parser.add_argument(
		"url"
	)

	return parser.parse_args()

def main(options):
	
	r = requests.get(options.url)
	#print(prepare_text(r.text))#needs more tests
	print(r.text)
	
def prepare_text(text):
	return text.encode('u8').decode("cp1251", 'ignore').replace("я", "¶")

if __name__ == "__main__":
	options = read_arguments()
	sys.exit(main(options))
