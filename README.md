# FetchTakeHome
### Steps to Run the App

SCREENSHOTS HERE ->  https://docs.google.com/document/d/18EO_mJCfIrrk9MIBb36oWr10Gz0m3WMDHYQjIBwB0D0/edit?usp=sharing

Just Open the FetchRecipes.xcodeproj file and run...
The app will show the main list of recipes, if you wish to reload them you can just drag the screen and any new recipes or changes made in this url will appear here. 
At the top of the application you will see 3 options "Normal", "Malformed", and "Empty" you can change between on any of these and the table will update for that option. 
For Malformed you will be able to see and error message and for empty you will just have an empty list

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

My focus was the Network Manager, since it contains the request methods

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I decided to work on this projects by parts and divided the work on a task, since some of the topics were new for me I spend some time 
researching it and seeing what best practices I could use 

1. Recipes list 1hr
2. Disk Manager and Network manager 2hr
4. Displaying Recipe Details 1hr
5. Testing 1hr


### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

Not really, I decided to take my time to cover as many of the requested items as possible

### Weakest Part of the Project: What do you think is the weakest part of your project?

I would say the async await part could be better since it was the topic that i didn't fully understand, my approach was to make it with regular completion blocks first and then do research and migrate it to use Async/await , i kept the older methods too and added tests 

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

This was my first time using some of the these tools and I wanted to take my time to learn them and implement it in my App, this was my biggest takeaway now,
that I learn how to do some of the common principles as singleton, testing , JSON Decoders and more
