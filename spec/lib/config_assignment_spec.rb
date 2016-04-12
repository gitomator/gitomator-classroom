require 'classroom_automator/assignment'
require 'securerandom'

describe ClassroomAutomator::Assignment do

  it "should create an attr_reader for each configuration attribute" do
    # Create a hash with arbitrary configuration data
    config = {
      'a' + SecureRandom.hex => SecureRandom.hex,
      'a' + SecureRandom.hex => 42,
      'a' + SecureRandom.hex => Time.now
    }

    assignment = ClassroomAutomator::Assignment.from_hash(config)

    config.each do |attr_name, attr_value|
      expect(assignment.send(attr_name)).to eq(attr_value)
    end
  end




  describe 'repos configuration' do

    it "should handle repo-name only" do
      repos = ['repo#1', 'repo#2', 'repo#3']
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo|
        expect(assignment.repos[repo]).to eq([])
      end
    end


    it "should should handle { repo-name => username }" do
      repos = [
        {'repo#1' => 'username#1'},
        {'repo#2' => 'username#2'},
        {'repo#3' => 'username#3'}
      ]
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo2student|
        repo     = repo2student.keys.first
        students = repo2student.values
        expect(assignment.repos[repo]).to eq(students)
      end
    end


    it "should should handle { repo-name => [username1, ...] }" do
      repos = [
        {'repo#1' => ['username#1', 'username#2']},
        {'repo#2' => ['username#3']},
        {'repo#3' => ['username#4', 'username#5', 'username#6']}
      ]
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo2students|
        repo     = repo2students.keys.first
        students = repo2students[repo]
        expect(assignment.repos[repo]).to eq(students)
      end
    end


    it "should should handle mixed formats" do
      repos = [
        'repo#1',
        { 'repo#2' => 'username#2' },
        { 'repo#3' => ['username#3', 'username#4', 'username#5'] }
      ]

      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })
      expect(assignment.repos['repo#1']).to eq([])
      expect(assignment.repos['repo#2']).to eq(['username#2'])
      expect(assignment.repos['repo#3']).to eq(['username#3', 'username#4', 'username#5'])
    end


    it "should fail on duplicate repo names" do
      repos = [
        { 'repo#1' => 'username#2' },
        { 'repo#1' => ['username#3', 'username#4', 'username#5'] }
      ]

      expect do
        ClassroomAutomator::Assignment.from_hash({'repos' => repos })
      end.to raise_error(ClassroomAutomator::DuplicateRepoError)
    end

  end

end
