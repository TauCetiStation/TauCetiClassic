#!/usr/bin/env python3

import argparse, os, sys

from slacker import Slacker

def read_arguments():
	parser = argparse.ArgumentParser(
		description="SS13-slack message integration."
	)
	
	parser.add_argument(
		"channel", help="Name of channel or group"
	)
	
	parser.add_argument(
		"text", help="What we send to slack (text)", type=os.fsencode
	)
	
	parser.add_argument(
		"--attachment_message", help="What we send to slack (attachment)", nargs="?", type=os.fsencode
	)

	parser.add_argument(
		"--name", help="Bot name", nargs="?"
	)
	
	parser.add_argument(
		"--icon", help="Bot emoji icon", nargs="?"
	)

	return parser.parse_args()

def main(options):
	
	slack = Slacker("SLACK-TOKEN-HERE")
	
	send_as_user = True
	
	if(options.name or options.icon):
		send_as_user = False
	
	options.text = prepare_text(options.text)
	
	if(options.attachment_message):
		options.attachment_message = [{"text": prepare_text(options.attachment_message)}]
	
	slack.chat.post_message(options.channel, options.text, attachments=options.attachment_message, username=options.name, icon_emoji=options.icon, as_user=send_as_user, unfurl_links=False, unfurl_media=False, link_names=True)
	
def prepare_text(text):
	return text.decode("cp1251").replace("¶", "я").replace("&#255;", "я")

if __name__ == "__main__":
	options = read_arguments()
	sys.exit(main(options))