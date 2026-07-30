# Formatters

The following formatter implementation are provided by default.

They are implemented by adding the `report_print` method onto the specified class, and so will be inherited as expected and can be overwritten as needed.

## Simple Values

A number of simple value types are configured to produce colorized versions of their `inspect` output.

    rp :symbols
    rp "strings"

    # All Numeric types
    rp 1
    rp 0.5
    rp Float::INFINITY
    rp 1i * 1i
    rp Rational(2, 3)

    # Constants
    rp true
    rp false
    rp nil

Output:

<pre>
<span style="color:var(--code-blue)">:symbols<span style="color:var(--code-green)">
"strings"<span style="color:var(--code-purple)">
1
0.5
Infinity
(-1+0i)
(2/3)<span style="color:var(--code-blue)">
true
false
nil</span>
</pre>

## `Object`

    class A
      def initialize
        @name = self.class.name
      end
    end

    class B < A
      def initialize
        super
        @field = A.new
      end
    end

    rp B.new

Output:

<pre>
<span style="color:var(--code-orange)">B</span> <span style="color:var(--code-gray)">0x2b0</span>
  <span style="color:var(--code-cyan)">@name</span> = <span style="color:var(--code-green)">"B"</span>
  <span style="color:var(--code-cyan)">@field</span> = <span style="color:var(--code-orange)">A</span> <span style="color:var(--code-gray)">0x2b8</span>
    <span style="color:var(--code-cyan)">@name</span> = <span style="color:var(--code-green)">"A"</span>
  <span style="color:var(--code-blue)">end
end</span>
</pre>

## `Module`

    rp Class

Output:

<pre>
<span style="color:var(--code-orange)">Class</span>
</pre>


## `Array`

    rp [1, "two", [[]]]

Output:

<pre>
[
  <span style="color:var(--code-purple)">1</span>,
  <span style="color:var(--code-green)">"two"</span>,
  [
    []
  ]
]</span>
</pre>

## `Hash`

    rp({
      "one" => 1,
      two: {
        [1, 2] => {}
      }
    })

Output:

<pre>
{
  <span style="color:var(--code-green)">"one"</span> => <span style="color:var(--code-purple)">1</span>,
  <span style="color:var(--code-cyan)">two:</span> {
    [
      <span style="color:var(--code-purple)">1</span>,
      <span style="color:var(--code-purple)">2</span>
    ] => {}
  }
}</span>
</pre>

## `Set`

    rp Set[1, "thing", Set[]]

Output:

<pre>
<span style="color:var(--code-orange)">Set</span>[
  <span style="color:var(--code-purple)">1</span>,
  <span style="color:var(--code-green)">"thing"</span>,
  <span style="color:var(--code-orange)">Set</span>[]
]</span>
</pre>

## `Data`

    Direction = Data.define(:x, :y)
    Velocity = Data.define(:speed, :direction)

    rp Velocity[100, Direction[0.6, 0.8]]

Output:

<pre>
<span style="color:var(--code-blue)">Velocity</span>[
  <span style="color:var(--code-cyan)">speed</span>: <span style="color:var(--code-purple)">100</span>,
  <span style="color:var(--code-cyan)">direction</span>: <span style="color:var(--code-blue)">Direction</span>[
    <span style="color:var(--code-cyan)">x</span>: <span style="color:var(--code-purple)">0.6</span>,
    <span style="color:var(--code-cyan)">y</span>: <span style="color:var(--code-purple)">0.8</span>
  ]
]</span>
</pre>

## `Struct`

    Player = Struct.new(:health, :mana)

    rp Player.new(100, 200)

Output:

<pre>
<span style="color:var(--code-orange)">Player</span>( <span style="color:var(--code-gray)">0x298</span>
  <span style="color:var(--code-cyan)">health</span>: <span style="color:var(--code-purple)">100</span>,
  <span style="color:var(--code-cyan)">mana</span>: <span style="color:var(--code-purple)">200</span>
)</span>
</pre>

Note that the object id is included for `Struct` but not for `Data` as the latter is a flyweight while the former is essentially an ordinary class.
