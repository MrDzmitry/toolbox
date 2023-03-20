# toolbox
Just helpful tools.

Task+Timeout.swift was created after I tried to use this code https://gist.github.com/swhitty/9be89dfe97dbb55c6ef0f916273bbb97. 
This code looks cool but it has one hidden problem: timeout don't work if task doesn't support cancellation.
This code based on dispatch group, but dispatch group has one tricky behaviour: dispatch group doesn't let you finish it until
all tasks are finished. Sometimes it can be bonus, sometimes not.

My code works in opposite way: it doesn't cancel any task and just throws error when time is over. But task continues. It let
you finish necessary work in background.
