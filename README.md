# Alexa Recipes #
Alexa Recipes is an Amazon Echo voice skill and accompanying web app. Users can browse recipes online and save them for access on their Amazon Echo device. Then they can interact with Alexa via voice to work their way through the recipe step by step.

## Problem Statement ##
Many people use laptops, phones, or other screened devices to reference recipes while cooking. However, it can be inconvenient to constantly unlock these devices and to interact with them with full or messy hands in the kitchen. My capstone will provide one solution to this problem by allowing users to interact with their chosen recipes via voice.

## Feature Set ##
**Link accounts**: Users will create an account on my website and link it to their existing Amazon (Echo) account via OAuth.  
**Input and save recipes**: Users will have two options for inputting and saving recipes to their account for access on their Echo device. Under one strategy, the user will input the recipe from scratch via a form, which will include fields for ingredients and the recipe steps. The alternative is to submit a link to the recipe on Yummly, which is a large database of recipes from popular sites like [Allrecipes](http://allrecipes.com/). My site's integration of the [Yummly API](https://developer.yummly.com/) will provide a recipe stub with basic information on the recipe already filled out. However, the user will still be required to copy the recipe steps into my website form (this information is not provided by the API).  
**Interact with recipes**: Via voice, users will launch the Recipes skill on their Echo device and then open a specific recipe of their choice. An intuitive voice interface will let users ask what step of the recipe they're on and what's coming up. Users will also be able to ask basic questions about ingredients and preparation time.  

**Other potential features (non-MVP)**:  
**Share recipes**: Users can publish their own recipes to share with other Alexa Recipes users.  
**Browse by category via voice**: With recipes categorized by type, users can ask Alexa to name aloud which recipes of a certain type a user has saved.

## Technology Choices ##
**Amazon Echo/Alexa**: I'll be creating an Amazon Echo skill by using the [Alexa Skills Kit](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/getting-started-guide).  
**OAuth**: Users will link their account on my website to their Amazon account used on their Echo device.  
**Background jobs (email)**: I'll send email to users to confirm their account on my website and the successful linking of their account with their current Amazon account.   
**MongoDB**: Recipes and user info will be saved as MongoDB documents.  
**SSL**: To be published as an Alexa Skill, my application must make requests over HTTPS.   
