bulk-mode
=========

When you have limited cash, you want to maximise how much food you can put in your body.
So when you walk into taco bell, and you're wondering what to get, simply use **bulk-mode**.

You can either manually do a request to the webserver with the amount or you can text the service if you set up a twilio number!

GET
`http://<url>/best_for?wallet=AMOUNTHERE`

`AMOUNTHERE` is the numeric amount that you have to work with

ex.
`http://localhost:4567/best_for?wallet=10`

There is an optional field, `criteria`. Valid values are `calories` and `protein`.

`http://localhost:4567/best_for?wallet=10`


If you set up a twilio webhook, point it to `<url>/best_for` with a POST request.
Send a text with the following format:

`10.00 protein`
OR
`15`

If you leave off the criteria it will default to calories.
