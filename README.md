# awsipfilter

This is a docker image that will proxy incoming http requests to allow only those published by Amazon here: https://ip-ranges.amazonaws.com/ip-ranges.json .
A Node.js app runs hourly (via a cronjob) to check the published list and update the filter.

Nginx is then used to proxy incoming requests (if allowed) to a downstream application.

Notes: This works, though the forwarding is currently hardcoded. Plan to make that generic as a next step. I'm also not much of a Node.js developer, so please feel free to point out deficiencies in the implementation there or send a pull request.


