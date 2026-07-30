A hybrid between PrettyPrint and AwesomePrint/AmazingPrint. Providing you both a stylish readable default, and the ability to customize it as needed.

The name ReportPrint comes from the desire to output detailed reports of the program state at a given point in time, rather than merely inspecting an object.

## Usage

    require 'report_print'

    class Example
      def initialize
        @foo = { a: [1,2,3] }
        @bar = Object.new
      end
    end

    rp Example.new

Output:

<pre>
<span style="color:var(--code-orange)">Example</span> <span style="color:var(--code-gray)">0x2a0</span>
  <span style="color:var(--code-cyan)">@foo</span> = {
    <span style="color:var(--code-cyan)">a:</span> [
      <span style="color:var(--code-purple)">1</span>,
      <span style="color:var(--code-purple)">2</span>,
      <span style="color:var(--code-purple)">3</span>
    ]
  }
  <span style="color:var(--code-cyan)">@bar</span> = <span style="color:var(--code-orange)">Object</span> <span style="color:var(--code-gray)">0x2a8<span style="color:var(--code-blue)">
end</span>
</pre>

See ReportPrint::Dsl#rp for the documentation of the global `rp` method.

## Features

ReportPrint comes with custom printers for the following standard library classes:

* `Object`
* `Module`
* `Array`
* `Hash`
* `Set`
* `Data`
* `Struct`

In addition it will produce colorized `inspect` output for the following classes:

* `Symbol`
* `String`
* `Numeric`
* `TrueClass`
* `FalseClass`
* `NilClass`

See the page on Formatters for examples of each.

### Customization

Similarly to PrettyPrint you can define the `report_print` method on a class to customize the rendering of instances of that class.

    class Production
      attr_accessor :left, :right

      def report_print(rp)
        rp.inline(" ") do
          rp.rp(left)
          rp.write("=>")
          right.each do |token|
            rp.rp(token)
          end
        end
      end
    end

See Customization for a guide on how to use the various methods provided by the `rp` object above.

See ReportPrint::Printer for the API documentation of printer object.

### Design

The printed output intentionally avoids the standard inspect format of `#<Object:0x000078c7430fd6c8>` in favour of relying primarily on line breaks and indentation to delimit the start and end of objects.

Similarly a conscious choice was made not to attempt any kind of midline alignment like `ap` does. Midline alignment may sometimes be pretty but it pays a substantial readability penalty for it.
