# Customization

To set up customized printing for your own classes, you need to define the `report_print` instance method.

When you then go to print the object, the method you defined will be called passing in a ReportPrint::Printer instance that you can use to print things.

The printer is composed of the following 4 methods:

* ReportPrint::Printer#multiline
* ReportPrint::Printer#inline
* ReportPrint::Printer#write
* ReportPrint::Printer#rp

The `multiline` and `inline` methods modify the behaviour of the `write` method to enable you to specify how elements are joined and lines are separated.

The `rp` method simply calls the `report_print` method of the specified object passing in the printer.

## `multiline`

The `multiline` method creates a new multiline context and executes the provided block within it, resetting the printer context back at the end of the block.

Inside a multiline context each call to `write` will write its output on a new line indented as per the current indent level.

If you specify a `separator` for the multiline context, then that will be written before the newline on every line except the first line of the multiline context.

At the end of a multiline context the content of `after` is written into the outer context, unless `after_empty` is false and nothing was written inside the context.

Example:

```
class ::Array < ::Object
  def report_print(rp)
    rp.write("[")
    rp.multiline(after: "]", separator: ",") do
      to_a.each do |item|
        rp.rp(item)
      end
    end
  end
end
```

In this example we also see the outline of the common pattern intended for when you are putting delimiters around a block. You write the opening token manually, but rely on the `after:` keyword argument to write the closing token.

The value passed to `after:` will be written without any separator before it. This pattern allows us to do the above safely without wrapping things in an extra `inline` block to prevent a separator being placed before the `"]"`.

## `inline`

The `inline` method creates a new inline context and executes the provided block within it, resetting the printer context back at the end of the block.

When an inline context is placed within a multiline context we will say that it defines a `line`.

For each line the first call to `write` behaves the same as one in the containing multiline context.

Within an inline context the `inline_separator` defines a sequence to be written between two writes in that context.

When inline contexts are nested the rules are applied such that all of the writes within a child context are treated as one write for the purposes of joining.

Example:

```
rp.inline("+") do
  rp.inline("-") do
    rp.write(1)
  end
  rp.inline("/") do
    rp.write(2)
  end
end

# => "1+2"

rp.inline("+") do
  rp.inline("-") do
    rp.write(1)
    rp.write(2)
  end
  rp.inline("/") do
    rp.write(3)
    rp.write(4)
  end
end

# => "1-2+3/4"
```

## Writing Defensively

When creating a `report_print` method it is very important to be explicit about how you want the text to be written.

**You cannot safely assume anything about the outer context.**

Thus if you want items to be rendered on the same line you always need to enclose them in an `inline` context. Same goes for multiple lines and a multiline context.

Example:

```
# Bad: assumes that it is in an inline context with a blank inline_separator
def report_print(rp)
  rp.write("Item")
  rp.write("[")
  rp.multiline(after: "]", separator: ",") do
    each do |sub_item|
      rp.rp(sub_item)
    end
  end
end

# Good: sets up an inline context
def report_print(rp)
  rp.inline("") do
    rp.write("Item")
    rp.write("[")
    rp.multiline(after: "]", separator: ",") do
      each do |sub_item|
        rp.rp(sub_item)
      end
    end
  end
end
```

## Only use Separators for Separators

Separators are only written between two writes, so you probably don't want to use them for some things that feel like separators but don't have that same property.

For example:

```
class Assignment
  # Bad: if @rhs is empty we probably still want to render an =.
  # Otherwise users won't be able to tell that it is an assignment being
  # printed.
  def report_print(rp)
    rp.inline(" = ") do
      rp.rp(@lhs)
      rp.rp(@rhs) if @rhs
    end
  end

  # Better
  def report_print(rp)
    rp.inline(" ") do
      rp.rp(@lhs)
      rp.write("=")
      rp.rp(@rhs) if @rhs
    end
  end
end
```
