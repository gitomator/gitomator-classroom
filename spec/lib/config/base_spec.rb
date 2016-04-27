require 'gitomator/classroom'
require 'gitomator/classroom/config/base'
require 'securerandom'
require 'tmpdir'

describe Gitomator::Classroom::Config::Base do



  it "should set the config attribute, when instantiating from hash" do
    expected = {
      'a' + SecureRandom.hex => SecureRandom.hex,
      'a' + SecureRandom.hex => 42,
      'a' + SecureRandom.hex => Time.now
    }
    actual = Gitomator::Classroom::Config::Base.from_hash(expected).config
    expect(expected).to eq(actual)
  end



  describe 'Subclasses' do


    it "should have attr_reader when declaring a property" do
      class SubClass1 < Gitomator::Classroom::Config::Base
        property :name
      end

      foo = SubClass1.from_hash({ 'name' => 'Alice' })
      expect(foo.name).to eq('Alice')
    end


    it "should not have attr_reader without declaring a property" do
      class SubClass2 < Gitomator::Classroom::Config::Base
        # No properties decalred
      end

      foo = SubClass2.from_hash({ 'name' => 'Alice' })
      expect(foo).to_not respond_to(:name)
    end



    it "should raise an error, if a required property is missing" do
      class SubClass3 < Gitomator::Classroom::Config::Base
        property :name, { :required => true }
      end

      expect do
        SubClass3.from_hash({ 'age' => 27 })
      end.to raise_error(Gitomator::Classroom::Exception::InvalidConfig)
    end


    it "should not raise an error, when a required property is present" do
      class SubClass4 < Gitomator::Classroom::Config::Base
        property :name, { :required => true }
      end
      SubClass4.from_hash({ 'name' => 'Alice' })
    end



    it "should use the default property value, if the value is missing" do
      class SubClass5 < Gitomator::Classroom::Config::Base
        property :name, { :default => 'John Doe' }
      end
      expect(SubClass5.from_hash({}).name).to eq('John Doe')
    end


    it "should not use the default property value, if the value is specified" do
      class SubClass6 < Gitomator::Classroom::Config::Base
        property :name, { :default => 'John Doe' }
      end
      expect(SubClass6.from_hash({'name' => 'Alice'}).name).to eq('Alice')
    end



    it "should raise an error, if a directory property does not exist" do
      class SubClass7 < Gitomator::Classroom::Config::Base
        property :home, { :is_dir => true }
      end

      # Let's come up with a path that (most likely) doesn't exist
      path = "/#{SecureRandom.hex}/#{SecureRandom.hex}/#{SecureRandom.hex}"
      expect do
        SubClass7.from_hash({ 'home' => path })
      end.to raise_error(Gitomator::Classroom::Exception::InvalidConfig)
    end


    it "should not raise an error, if a directory property exists" do
      class SubClass8 < Gitomator::Classroom::Config::Base
        property :home, { :is_dir => true }
      end

      Dir.mktmpdir { |path| SubClass8.from_hash({ 'home' => path }) }
    end



  end

end
