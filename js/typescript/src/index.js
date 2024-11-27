"use strict";
/*
2 way to run ts file
+ First way
    tsc index.ts
    node index.js
+ Second way
    ts-node index.ts
 */
Object.defineProperty(exports, "__esModule", { value: true });
/*
JavaScript handles object keys when defining an object,
so let's clarify the difference between obj1 and obj2 in your example:

obj1 = {"key1": "val1"}:

In this case, "key1" is a string key.
The key is explicitly written in quotes,
which is completely valid in JavaScript.
This is commonly used when you want to ensure the key is treated as a string,

obj2 = {key1: "val1"}:

Here, key1 is implicitly treated as a string key,
even though it's not wrapped in quotes.
So in this case, key1 is automatically interpreted as the string "key1".

Conclusion:
In both cases, obj1 and obj2 are equivalent because, in JavaScript,
if the key is a valid identifier, you can omit the quotes,and the key will still be treated as a string.
 */
var telegraf_1 = require("telegraf");
var bot = new telegraf_1.Telegraf('7823021644:AAHKxSvdsnzjOj20cdqyGLaex10xIAWRpzU\n');
// This will log any message's chat ID
bot.on('message', function (ctx) {
    console.log('Group ID:', ctx.chat.id);
    // Also send it as a message
    ctx.reply("This group's ID is: ".concat(ctx.chat.id));
});
bot.launch();
