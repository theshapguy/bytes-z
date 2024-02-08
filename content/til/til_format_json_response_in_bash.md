+++

title = "Pretty Print JSON Reponse in Bash"
date = "2034-02-04"
draft = false

[taxonomies]
tags = ["bash", "cmd"]
categories = ["Today I Learned", "Bash"]


[extra]
lang = "en"
toc = false

+++

Pipe output into `python -m json.tool`

```bash
curl --request GET \
           --url http://shapath.com.np/posts/til_format_json_response_in_bash.json \
           --header 'Content-Type: application/json' \
           | python -m json.tool
```

```bash
## Pretty Printed Response
{
    "data": [
        {
            "type": "resposne",
            "id": "1",
            "attributes": {
                "title": "Pretty Printed",
                "body": "The shortest article. Ever.",
                "created": "2024-02-04T14:56:29.000Z",
                "updated": "2024-02-04T14:56:28.000Z"
            },
            "relationships": {
                "author": {
                    "data": {
                        "id": "42",
                        "type": "links"
                    }
                }
            }
        }
    ],
    "included": [
        {
            "type": "links",
            "id": "42",
            "attributes": {
                "link": "http://example.com",
                "domain": "example.com"
            }
        }
    ]
}
```