# One Trillion Dollars
One Trillion Dollars is a 3D adventure puzzle platformer where you find yourself in a strange world. You're presented with a mountain, one trillion dollars to be specific. Do you climb to the top, or try and help those around you? It was made for Down2Jam 4 in3 days, where the theme was Scaling.

The game falls under the ODA category (one dev army). Everything was made my me. No outside assets, no AI, nothing.

### Goals
I really wanted to explore new systems and mechanics this time around, and I wanted to continue learning and improving my 3D skills. I always thought the climbing mechanics in PEAK were neat, so I sort of emulated that a little bit in my own way. I wanted to learn more about the way to use vectors in three-dimensional space, and also designing large open-world environments. More on that below.

---

### Style
As I developed it, I started to move in the direction of those early 2000s education games. Something like Baldi's Basics. I do think its a neat aesthetic, that could definitely be done in a way that feels much more refined. Consistent sprite resolutions, fancier models, etc. I think it would be neat to revisit this style again in the future. It works really well for very abstract settings, and in my head, a mountain of a trillion dollars feels pretty abstract.

I found audio import settings to be super helpful. I wanted many of the recorded lines to be bitcrushed, but its a pain to have to filter every single one. Instead you can force a max bitrate level in the audio import settings. That way you can do it in a non-destructive way, and its super easy!

---

### Challenges
It took a bit of figuring out, but it was a great opportunity to learn about more 3D physics, especially when it comes to a physics-based character. I opted for a RigidBody3D instead of a CharacterBody3D. Not 100% sure if that was the move or not, but I think it gave me some more fine-tuned control over the way in which the player reacts to their environment. I would also like to explore using a character body as well.

That approach did require a lot of manual checks. I had to see if the player was on the floor, on a wall, in the air, etc. Lots of raycasts. Shapecasts would have been nice and easy, but for some reason, they are inconsistent in their results that are returned, so I just used multiple raycasts.

---

### Conclusion
I think I learned a lot working on this project. Some of which being:

#### The need for a toolkit
If I had a set of nodes and systems for basic stuff (saving/loading, menus, object interaction), I would have had a much easier time. This is something I want to work on

#### The need for a better sound workflow
I used a mix of audacity and FL Studio for this project. Audacity can be a bit frustrating at times, but FL Studio 20 (that I purchased for this jam), is really sick. I think I could easily see myself editing my sounds in there from now on. Then I just need one program for ALL the audio stuff.

#### ODA is lonely
It's a nice challenge occasionally to do everything yourself, but there's such a great opportunity to work with and meet new people. I think I'd like to create a team next time around. Hit me up if that sounds interesting to anyone!

#### Thanks for reading!
