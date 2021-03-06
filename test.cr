require "./anyolite.cr"

module SomeModule
  def self.test_method(int : Int32, str : String)
    puts "#{str} and #{int}"
  end
end

struct TestStruct

  property value : Int32 = -123
  property test : Test = Test.new(-234)

  def mrb_initialize(mrb)
    puts "Struct initialized!"
  end

end

class Test
  property x : Int32 = 0

  @@counter : Int32 = 0

  def self.increase_counter
    @@counter += 1
  end

  def self.counter
    return @@counter
  end

  def self.give_me_a_struct
    s = TestStruct.new
    s.value = 777
    s.test = Test.new(999)
    s
  end

  def test_instance_method(int : Int32, bool : Bool, str : String, float : Float32)
    puts "Old value is #{@x}"
    a = "Args given for instance method: #{int}, #{bool}, #{str}, #{float}"
    @x += int
    puts "New value is #{@x}"
    return a
  end

  # Gets called in Crystal and mruby
  def initialize(@x : Int32 = 0)
    Test.increase_counter()
    puts "Test object initialized with value #{@x}"
  end

  # Gets called in mruby
  def mrb_initialize(mrb)
    puts "Object registered in mruby"
  end

  # Gets called in Crystal unless program terminates early
  def finalize
    puts "Finalized with value #{@x}"
  end

  def +(other)
    Test.new(@x + other.x)
  end

  def add(other)
    ret = self + other
  end

  def output_this_and_struct(str : TestStruct)
    puts str
    "#{@x} #{str.value} #{str.test.x}"
  end

  def keyword_test(strvar : String, intvar : Int32, floatvar = 0.123, strvarkw : String = "nothing", boolvar : Bool = true, othervar : Test = Test.new(17))
    puts "str = #{strvar}, int = #{intvar}, float = #{floatvar}, stringkw = #{strvarkw}, bool = #{boolvar}, other.x = #{othervar.x}"
  end

  # Gets called in mruby unless program crashes
  def mrb_finalize(mrb)
    puts "Mruby destructor called for value #{@x}"
  end
end

MrbRefTable.set_option(:logging)

MrbState.create do |mrb|
  MrbWrap.wrap_module(mrb, SomeModule, "TestModule")
  MrbWrap.wrap_module_function_with_keywords(mrb, SomeModule, "test_method", SomeModule.test_method, {:int => Int32, :str => String})
  MrbWrap.wrap_constant(mrb, SomeModule, "SOME_CONSTANT", "Smile! 😊")

  MrbWrap.wrap_class(mrb, Bla, "Bla", under: SomeModule)
  MrbWrap.wrap_constructor(mrb, Bla)

  MrbWrap.wrap_class(mrb, TestStruct, "TestStruct", under: SomeModule)
  MrbWrap.wrap_constructor(mrb, TestStruct)
  MrbWrap.wrap_property(mrb, TestStruct, "value", value, [Int32])
  MrbWrap.wrap_property(mrb, TestStruct, "test", test, [Test])

  MrbWrap.wrap_class(mrb, Test, "Test", under: SomeModule)
  MrbWrap.wrap_class_method(mrb, Test, "counter", Test.counter)
  MrbWrap.wrap_constructor_with_keywords(mrb, Test, {:x => {Int32, 0}})
  MrbWrap.wrap_instance_method_with_keywords(mrb, Test, "bar", test_instance_method, {:int => Int32, :bool => Bool, :str => String, :float => {Float32, Float32.new(0.4)}})
  MrbWrap.wrap_instance_method(mrb, Test, "add", add, [Test])
  MrbWrap.wrap_instance_method(mrb, Test, "+", add, [Test])
  MrbWrap.wrap_property(mrb, Test, "x", x, [Int32])
  MrbWrap.wrap_class_method(mrb, Test, "give_me_a_struct", Test.give_me_a_struct)
  MrbWrap.wrap_instance_method(mrb, Test, "output_this_and_struct", output_this_and_struct, [TestStruct])

  MrbWrap.wrap_instance_method_with_keywords(mrb, Test, "keyword_test", keyword_test, {
    :floatvar => {Float32, 0.123}, 
    :strvarkw => {String, "nothing"}, 
    :boolvar => {Bool, true}, 
    :othervar => {Test, Test.new(17)}
  }, [String, Int32])

  mrb.load_script_from_file("examples/test.rb")
end

class Entity
  property hp : Int32 = 0

  def initialize(@hp)
  end

  def damage(diff : Int32)
    @hp -= diff
  end

  def yell(sound : String, loud : Bool = false)
    if loud
      puts "Entity yelled: #{sound.upcase}"
    else
      puts "Entity yelled: #{sound}"
    end
  end

  def absorb_hp_from(other : Entity)
    @hp += other.hp
    other.hp = 0
  end
end

class Bla
  def initialize
  end
end

# TODO: Accept MrbClass and Class

puts "Reference table: #{MrbRefTable.inspect}"
MrbRefTable.reset

puts "------------------------------"

module TestModule
end

MrbState.create do |mrb|
  test_module = MrbModule.new(mrb, "TestModule")

  MrbWrap.wrap_class(mrb, Entity, "Entity", under: test_module)

  MrbWrap.wrap_constructor_with_keywords(mrb, Entity, {:hp => {Int32, 0}})

  MrbWrap.wrap_property(mrb, Entity, "hp", hp, Int32)

  MrbWrap.wrap_instance_method_with_keywords(mrb, Entity, "damage", damage, {:diff => Int32})

  MrbWrap.wrap_instance_method_with_keywords(mrb, Entity, "yell", yell, {:sound => String, :loud => {Bool, false}})

  MrbWrap.wrap_instance_method_with_keywords(mrb, Entity, "absorb_hp_from", absorb_hp_from, {:other => Entity})

  mrb.load_script_from_file("examples/hp_example.rb")
end

puts "Reference table: #{MrbRefTable.inspect}"