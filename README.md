Nitron
===================

Introduction
----------
Nitron is an opinionated, loosely-coupled set of RubyMotion components designed to accelerate iOS
development, especially with simpler iOS apps. It provides meaningful
abstractions atop the strong foundation present in the iOS SDK.

This first release focuses on making Storyboard-based workflows enjoyable.

Installation
----------
Add the following line to your `Gemfile`:

`gem "nitron"`

If you haven't already, update your Rakefile to use Bundler. Insert the
following immediately before `Motion::Project::App.setup`:

```ruby
require 'rubygems'
require 'bundler'

Bundler.require
```

Then, update your bundle:

`bundle`

And build your application:

`rake`

Example
------
A modal view controller responsible for creating new `Tasks`:

```ruby
class TaskCreateViewController < Nitron::ViewController
  # The on class method is part of Nitron's Action DSL.
  # It wires the provided block to be an event handler for the specified outlet using the iOS target/action pattern.
  on :cancel do
    close
  end

  # Nitron emulates 'native' outlet support, allowing you to easily define outlets through Xcode.
  # The titleField and datePicker methods are created upon initial load by using metadata contained in the Storyboard.
  on :save do
    Task.create(title: titleField.text, due: datePicker.date)

    close
  end
end
```

Features
----------

* **Data Binding** - declaratively bind your model data to controls, either
  via code or Interface Builder
* **Outlet Support** - expose controls to your controllers via Interface Builder
* **Action Support** - Ruby DSL to attach event handlers to outlets
* **CoreData Models** - beginnings of a CoreData model abstraction uses
  XCode's data modeling tools with an ActiveRecord-like syntax

If you notice, many of these features aim at slimming down your
controllers. This is no accident: many iOS controllers have far too many
responsibilities. Glue code is a perfect target for metaprogramming, so
we're focusing on making beautiful controllers presently.

We're also careful to make these features modular, so you can mix them
into your existing controllers as needed.

CoreData ActiveRecord-ness
----------
Nitron strives to bring ActiveRecord based features to CoreData, including:

	Task.count
	Task.where("title contains[cd] ?", "some title")
	Task.where("title contains[cd] ?", "some title").order("created_at").count

Tutorial
----------
https://github.com/mattgreen/nitron/wiki/Tutorial

Examples
----------
https://github.com/mattgreen/nitron-examples

Caveats
---------

* Data binding doesn't use KVO presently. This is already in the works.
* Action support is limited to selecting a button or a table cell.
  Future releases will expand the DSL to support additional events.
* CoreData needs support for relationships and migrations.

License
-------

Nitron is released under the MIT license:

* http://www.opensource.org/licenses/MIT