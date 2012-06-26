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

CoreData ActiveRecord Support
-----------------

Nitron offers lots of your favorite ActiveRecord features for data manipulation and searching, including the following methods.

```ruby
# Querying Tasks

Task.all # Array of tasks

Task.pluck(:assignee_id) # returns array of non-distinct values
Task.uniq.pluck(:assignee_id) # now the array of id values is distinct

Task.first # First task or nil
Task.first! # First task or Nitron::RecordNotFound exception

Task.limit(1) # returns one task
Task.offset(5).limit(1) # grab the 6th task, as an array with one item in it
Task.where("title contains[cd] ?", "some") # grab all tasks with the title containing "some", case insensitive
Task.where("title contains[cd] ?", "some").count # db call to count the objects matching the conditions

Task.count # number of tasks in the system

Task.order("title", ascending: false) # Tasks order in reverse alphabetical order on title attribute

# Overriding existing query
scope = Task.where("status = ?", :open)
scope.except(:where).where("status = ?", :closed) # realized I really wanted closed items
scope.order(...).except(:order)
scope.limit(...).except(:limit)

# Daisy Chaining
Task.where(...).order(...).where(...).offset(10).limit(5).count # Yep, this works!
Task.where(...).order(...).all # array of the results

# Dynamic Finders
Task.find_by_status :open # returns the first task with a status of open, or nil
Task.find_all_by_status :open # returns array containing Tasks matching that status

# Creating tasks
Task.create assignee_id: 1, title: "some title" # runs validations, saves object into the default context if validations pass
Task.create! # Nitron::RecordNotSaved thrown if validations fail
Task.new # creates a new Task object, outside of a NSManagedObjectContext, optionally takes attributes

task = Task.new
task.save # will save, true if successful, false if failed
task.save! # will throw Nitron::RecordNotSaved if failed, contains errors object for validation messages
```

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
