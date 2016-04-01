require 'classroom_automator/config/assignment'
require 'securerandom'

describe ClassroomAutomator::Config::Assignment do

  it "should create an attr_reader for each configuration attribute" do
    # Create a hash with arbitrary configuration data
    conf_data = {
      'a' + SecureRandom.hex => SecureRandom.hex,
      'a' + SecureRandom.hex => 42,
      'a' + SecureRandom.hex => Time.now
    }

    conf = ClassroomAutomator::Config::Assignment.from_hash(conf_data)

    conf_data.each do |attr_name, attr_value|
      expect(conf.send(attr_name)).to eq(attr_value)
    end
  end


  describe 'handouts configuration' do

    it "should parse handouts configured with username only" do
      handouts = ['username#1', 'username#2', 'username#3']
      conf = ClassroomAutomator::Config::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |username|
        handout_id = username
        students   = [username]
        expect(conf.handouts[handout_id]).to eq(students)
      end
    end


    it "should parse handouts configured with handout-id and username" do
      handouts = [
        {'handout#1' => 'username#1'},
        {'handout#2' => 'username#2'},
        {'handout#3' => 'username#3'}
      ]
      conf = ClassroomAutomator::Config::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |handout|
        handout_id = handout.keys.first
        students   = handout.values
        expect(conf.handouts[handout_id]).to eq(students)
      end
    end


    it "should parse handouts configured with handout-id and a list of usernames" do
      handouts = [
        {'handout#1' => ['username#1', 'username#2']},
        {'handout#2' => ['username#3']},
        {'handout#3' => ['username#4', 'username#5', 'username#6']}
      ]
      conf = ClassroomAutomator::Config::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |handout|
        handout_id = handout.keys.first
        students   = handout[handout_id]
        expect(conf.handouts[handout_id]).to eq(students)
      end
    end


    it "should parse handouts of mixed formats" do
      handouts = [
        'username#1',
        { 'handout#2' => 'username#2' },
        { 'handout#3' => ['username#3', 'username#4', 'username#5'] }
      ]
      conf = ClassroomAutomator::Config::Assignment.from_hash({'handouts' => handouts })
      expect(conf.handouts['username#1']).to eq(['username#1'])
      expect(conf.handouts['handout#2']).to eq(['username#2'])
      expect(conf.handouts['handout#3']).to eq(['username#3', 'username#4', 'username#5'])
    end

  end

end
