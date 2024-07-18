import base64, io, requests, json, time, os, sys, argparse
from PIL import Image


class Text2ImageAPI:
    def __init__(self, api_key, secret_key):
        self.URL = 'https://api-key.fusionbrain.ai/'
        self.AUTH_HEADERS = {
            'X-Key': f'Key {api_key}',
            'X-Secret': f'Secret {secret_key}',
        }
        self.model_id = self.get_model()

    def get_model(self):
        response = requests.get(self.URL + 'key/api/v1/models', headers=self.AUTH_HEADERS)
        data = response.json()
        return data[0]['id']

    def generate(self, prompt, style="DEFAULT", images=1, width=1024, height=1024):
        params = {
            "type": "GENERATE",
            "numImages": images,
            "width": width,
            "height": height,
            "style": style,
            "generateParams": {
                "query": f"{prompt}"
            }
        }

        data = {
            'model_id': (None, self.model_id),
            'params': (None, json.dumps(params), 'application/json')
        }
        response = requests.post(self.URL + 'key/api/v1/text2image/run', headers=self.AUTH_HEADERS, files=data)
        data = response.json()
        return data['uuid']

    def check_generation(self, request_id, attempts=10, delay=10):
        while attempts > 0:
            response = requests.get(self.URL + 'key/api/v1/text2image/status/' + request_id, headers=self.AUTH_HEADERS)
            data = response.json()
            if data['status'] == 'DONE':
                return data['images']

            attempts -= 1
            time.sleep(delay)


def generateImage(input):
    api = Text2ImageAPI(input.api_key, input.secret_key)
    uuid = api.generate(input.prompt, input.style, width=input.generate_width, height=input.generate_height)
    imageBase64 = api.check_generation(uuid)[0]

    path = input.file_path
    imageBytes = base64.b64decode(imageBase64)
    imgPng = Image.open(io.BytesIO(imageBytes))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    resizedPng = imgPng.resize((input.target_width, input.target_height))
    resizedPng.save(path, 'png')

    # return base64 image
    sys.stdout.buffer.write(imageBase64.encode("utf-8"))

    return 0

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--prompt', type=str)
    parser.add_argument('--style', type=str)
    parser.add_argument('--target_width', type=int)
    parser.add_argument('--target_height',  type=int)
    parser.add_argument('--generate_width', type=int)
    parser.add_argument('--generate_height', type=int)
    parser.add_argument('--file_path', type=str)
    parser.add_argument('--api_key', type=str)
    parser.add_argument('--secret_key', type=str)
    args = parser.parse_args()

    sys.exit(generateImage(args))

