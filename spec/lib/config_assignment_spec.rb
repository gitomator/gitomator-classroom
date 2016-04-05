require 'classroom_automator/assignment'
require 'securerandom'

describe ClassroomAutomator::Assignment do

  it "should create an attr_reader for each configuration attribute" do
    # Create a hash with arbitrary configuration data
    conf_data = {
      'a' + SecureRandom.hex => SecureRandom.hex,
      'a' + SecureRandom.hex => 42,
      'a' + SecureRandom.hex => Time.now
    }

    conf = ClassroomAutomator::Assignment.from_hash(conf_data)

    conf_data.each do |attr_name, attr_value|
      expect(conf.send(attr_name)).to eq(attr_value)
    end
  end


  describe 'handouts configuration' do

    it "should parse handouts configured with repo-name only" do
      handouts = ['repo#1', 'repo#2', 'repo#3']
      conf = ClassroomAutomator::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |repo|
        expect(conf.handouts[repo]).to eq([])
      end
    end


    it "should parse handouts configured with repo-name and username" do
      handouts = [
        {'repo#1' => 'username#1'},
        {'repo#2' => 'username#2'},
        {'repo#3' => 'username#3'}
      ]
      conf = ClassroomAutomator::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |handout|
        repo     = handout.keys.first
        students = handout.values
        expect(conf.handouts[repo]).to eq(students)
      end
    end


    it "should parse handouts configured with repo-name and a list of usernames" do
      handouts = [
        {'repo#1' => ['username#1', 'username#2']},
        {'repo#2' => ['username#3']},
        {'repo#3' => ['username#4', 'username#5', 'username#6']}
      ]
      conf = ClassroomAutomator::Assignment.from_hash({'handouts' => handouts })

      handouts.each do |handout|
        repo     = handout.keys.first
        students = handout[repo]
        expect(conf.handouts[repo]).to eq(students)
      end
    end


    it "should parse handouts of mixed formats" do
      handouts = [
        'repo#1',
        { 'repo#2' => 'username#2' },
        { 'repo#3' => ['username#3', 'username#4', 'username#5'] }
      ]

      conf = ClassroomAutomator::Assignment.from_hash({'handouts' => handouts })
      expect(conf.handouts['repo#1']).to eq([])
      expect(conf.handouts['repo#2']).to eq(['username#2'])
      expect(conf.handouts['repo#3']).to eq(['username#3', 'username#4', 'username#5'])
    end


    it "should fail on duplicate repo names" do
      handouts = [
        { 'repo#1' => 'username#2' },
        { 'repo#1' => ['username#3', 'username#4', 'username#5'] }
      ]

      expect do
        ClassroomAutomator::Assignment.from_hash({'handouts' => handouts })
      end.to raise_error(ClassroomAutomator::DuplicateRepoError)
    end

  end

end
