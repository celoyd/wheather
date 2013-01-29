Hi! This is a set of scripts for sieving cloudless pixels out of satellite images in a fairly fast and foolproof way.

To see things I've done with (various versions of) this tool, please have a look around http://www.flickr.com/photos/vruba/sets/72157631622037685/with/8017203149/ . In the caption for http://www.flickr.com/photos/vruba/8017203149/in/set-72157631622037685 I explained the basic operation a little. I want to do some clearer documentation of the core concept here, but I'm a little busy: feel free to remind me.


To understand how everything fits together here, I'm going to walk you through making a composite. We're going to do this:

1. Download some satellite images.
2. Split them into strips.
3. Sort the strips, pixelwise, to remove cloud cover.
4. Average the (presumptively) cloudless strips.
5. Rejoin the strips into a (presumptively) cloudless image.

The strip stuff is just for efficient parallelization on a multicore machine and can be skipped.

Requirements not included:

+ PIL, the python image library
+ NumPy, the python math library
+ jpegtran, the JPEG translation utility
+ montage, in the ImageMagick package

In OS X by default, I'm pretty sure:
+ zsh, for leading 0s in expansions like {06..01}
+ curl, for convenient expansions in URLs

If you have pip and Homebrew:
    $ pip install PIL numpy
    $ brew install imagemagick jpeg


# 0

cd into the wheather directory. We're going to do this sloppy and scatter files every which way.


# 1. Download some satellite images

I'm going to call these images "raw", but of course they are in fact channel-composited, draped, projected, filled with in-band nulls for missing data, and JPEG-compressed between the satellite and us. For *our* purposes they're raw.

There are many sources for raws. Let's use http://www.pecad.fas.usda.gov/cropexplorer/modis_summary/

I'm clicking the southernmost mostly-land grid square on Africa, because I happen to know it works well, but you can do whatever you want. Notice that the rows are named in ascending order, along the y axis, instead of the usual descending order for computer images.

Now I'm looking at http://www.pecad.fas.usda.gov/cropexplorer/modis_summary/modis_page.cfm?regionid=world&modis_tile=r06c22

Depending on the time of day, you may see nothing, just Terra (morning) images, or morning and afternoon (Aqua) images. If you don't see both, click "previous day" near the top.

We want true-color images. For this example, we'll use 1 km imagery. If I click on the Terra 1 km for today, I see: http://www.pecad.fas.usda.gov/cropexplorer/modis_summary/modis_fullpage.cfm?modis_tile=r06c22&dt=2013008&sat_name=terra&img_res=1km&modis_date=01/08/13&cntryid=

The image's address is: http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r06c22/2013008/RRGlobal_r06c22.2013008.terra.1km.jpg

The structure of the interesting part is:

/RRGlobal_r06c22 -- which grid cell (row 6, column 22)

/2013008 -- year and day-of-year

/RRGlobal_r06c22 -- the grid cell again, in the filename part

.2013008 -- the year and day-of-year again, in the filename part

.terra -- which sensor/satellite it's from; could also be "aqua"

.1km -- north-south ground distance per pixel

.jpg -- "just please go"?

For simplicity let's get the last 30 days of 2012. That's early winter here, so it should be early summer in SA, which should be around peak greenness. The repeated day code means we have to set a variable to make the download work:

    mkdir raws
    cd raws
    for day in 2012{336..365}; do curl -O "http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r06c22/$day/RRGlobal_r06c22.$day.terra.1km.jpg"; done

(We could replace "terra" with "{terra,aqua}" and curl would know what to do, but I'm trying to keep this simple.)

Have a glance at the images. They should be 1024 by 1024, about a quarter of a megabyte, and show a mix of ground cover, clouds, and missing data where the satellite swaths don't overlap. (The MODIS people seemeded to switch from showing missing data as white to black a few months ago. Must remember to look into that.)

Let's see what a straight average looks like:

    cd ..
    python avgimg.py raws/* avg.png

This is pretty cool in its own right, but from a persnickety point of view we can complain about the mottledness and the dark sawteeth of black missing data along the top.



# 2. Split them into strips.

Okay, this is the really, really gross part. The script called slicey.sh has a bunch of hardcoded numbers to, as it is now, split 1024 by 1024 images into eight 1024 by 128 images. It does this by taking a given image and throwing it at jpegtran 8 times in a row. My hope is that JPEG decoding is so optimized, and the disk cache is smart enough, that this isn't very slow. My hope is false. This is dumb.

The reason we don't use one of the many fine tile scripts out there is that the JPEG compression on the raws is already stronger than I'd like. I really don't want to recompress the JPEG.  jpegtran is the only tool I know of that will write out a truly lossless crop of a JPEG region. We could write out PNGs instead of JPEGs, but the disk i/o and storage would be insane. Might still be worth it.

You can see why I consider this the weak link of my process as it stands.

So. If you cleverly disregarded my use of 1024x images, go in slicey.sh and edit it as appropriate now.

Here's the slice step:

    zsh slicey.sh raws

You should now see a folder called raws with directories called 0..7 in it, each with 30 image slices.



# 3. Sort the strips, pixelwise, to remove cloud cover.

Okay! Now we're going to do what I think of as the cube operation -- the actual work of this whole project. Conceptually, we arrange all the pixels in all our images into a rectangular solid (cube, speaking very loosely) and sort every z-axis column by a function that scores pixels according to whether they look like a cloud, then throw away all but the least-cloudy-looking layers.

The main python file for this is buff-cube.py, so called because of an implementation detail that I can explain at further length but won't. (Okay, real quick, instead of storing all the pixels, we only store as many as we know we're going to keep, and let incoming good pixels displace them. But to avoid a full re-sort every time a new layer comes in, we buffer new images in small groups. Thus "buff".)

buff-cube.py is hard-coded (on line 12) to generate, from n input images (30 in this case), n/4 + 2 output images. In other words, basically the top quarter of the quality cube. Change that as you see fit. Obviously it should be a parameter eventually.

There's a script called cube-driver.sh whose main purpose is to let you pick how many cores you want to use at once. I have 4 cores on this machine, and I'm okay maxing them all out, so I'm going to type:

    zsh cube-driver.sh 0 3

They're backgrounded so you won't necessarily see a prompt when it's done, just four lines of, in this case, "saving 7". I should fix that. It should run at very roughly one image per 2-3 GHz core per second. Now I'm running the second batch:

    zsh cube-driver.sh 4 7



# 4. Average the (presumptively) cloudless strips.

Now we have pixel-sorted slices in a directory called cube. Let's average them. To do: script for this.

    mkdir final-slices
    for slice in {0..7}; do python avgimg.py cube/$slice/* final-slices/$slice.png; done



# 5. Rejoin the strips into a (presumptively) cloudless image.

And now we splice them together:

    montage -mode concatenate -tile 1x final-slices/{0..7}.png final.png
    open final.png

Ta-da!

You can still see some significant artifacts. There's mottling and even a little bit of cloud in the ocean. This will disappear if you use more input images, or they're clearer. But the basics should be clear.