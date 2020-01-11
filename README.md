# App::AngrierFruitSalad — I am Using the Computer

Once upon a time there was the [Angry Fruit
Salad](https://github.com/doriantaylor/p5-app-angryfruitsalad), which
was a demonstration project to automatically render a graph database
as a website. It was called that because by default, every vocabulary
in the graph was given a slice of the colour spectrum, making every
page [a garish shotgun blast of rainbow
text](http://www.catb.org/jargon/html/A/angry-fruit-salad.html).

For a lot of reasons, the Angry Fruit Salad wasn't very good. Mainly,
it wasn't very good because you couldn't really _do_ anything with it
other than just look at it, and it wasn't especially nice to look at.
But it did prove a point:

There are a lot of things on the Web which are not _pages_ per se, but
rather some kind of _record_ or structured data object. A "page",
then, is just _one_ possible representation of such an object (contra
say, a wad of JSON, a spreadsheet, whatever).

When these objects are individually _addressable_, and respresented as
Web pages, it turns out to be _extremely_ useful for navigating and
comprehending vast sets of interrelated information; indeed, creating
these systems is what we Web professionals spend most of our time doing.

If, however, we can _systematize_ the
represent-structured-data-objects-as-Web-pages part of the process, we
can shrink it to a _point_, leaving us much more time to work with the
_content_, rather than fuss over the technical minutiae of its
representation. This is what the Angry Fruit Salad was intended to
achieve—and even _did_ to some extent.

The _Angrier_ Fruit Salad, then, is a reprise of these principles,
intended to actually _function_. This time around it is written in
Ruby, and demonstrates a number of other ideas on top of the basic
premise of "take a graph database and turn it into a website".

## Installation

For now, you will have to clone [the GitHub
repository](https://github.com/doriantaylor/rb-app-angrierfruitsalad).

Later, probably:

    $ gem install app-angrierfruitsalad

Or, [download it off
rubygems.org](https://rubygems.org/gems/app-angrierfruitsalad).

## Contributing

Bug reports and pull requests are welcome at
[the GitHub repository](https://github.com/doriantaylor/rb-app-angrierfruitsalad/issues).

## Copyright & License

©2020 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
