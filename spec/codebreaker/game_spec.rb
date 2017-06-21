require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    subject do
      game = Game.new
      game.start
      game
    end

    describe 'secret code and hint generation' do
      it 'should have 4 digits from 1 to 6 inclusive' do
        expect(subject.instance_variable_get :@code).to match /[1-6]{4}/
      end

      it 'should generate hint from digits that are in code' do
        code = subject.instance_variable_get :@code
        hint = subject.instance_variable_get :@hint
        expect(code).to include hint
      end
    end

    describe 'secret code guessing' do
      before do
        subject.instance_variable_set :@code, '1234'
      end

      it 'should raise exception if input is invalid' do
        [nil, '', 'abc', 'ab12'].each do |value|
          expect { subject.check value }
            .to raise_error(ArgumentError)
        end
      end

      inputs = ['43215', '3333', '1234', '5234', '1324', '12', '5154', '34', '5115']
      outputs = ['----', '+', :WIN, '+++', '++--', '++', '+-', '--', '-']

      inputs.length.times do |index|
        it 'should return result as value in array with name "outputs"' do
          expect(subject.check inputs[index]).to eq outputs[index]
        end
      end

      it 'should return 4 minuses' do
        subject.instance_variable_set :@code, '1224'
        expect(subject.check '2142').to eq '----'
      end
    end

    describe 'hint requesting' do
      it 'should return digit and then appropriate message' do
        hint = subject.hint
        code = subject.instance_variable_get :@code
        expect(code).to include hint

        hint = subject.hint
        expect(hint).to be_nil
      end
    end

    describe 'reading and writing score data' do
      before(:each) do
        subject.instance_variable_set :@code, '1234'
      end

      after(:each) do
        ['score.yaml', 'temp.yaml'].each do |filename|
          File.delete filename if File.exist? filename
        end
      end

      it 'should do nothing with game data if score file does not exist or hash value is invalid' do
        expect(Game.read).to be_nil
        expect(Game.read 'file').to be_nil
        expect(Game.read hashcode: 'hash').to be_nil
        expect(Game.read 'file', hashcode: 'hash').to be_nil
      end

      it 'should write data to default file and load all games' do
        subject.write 'GarrisonD', 'hashcode'
        expect(Game.read).to have(1).items

        subject.write 'GarrisonD Fake', 'hashcode'
        expect(Game.read).to have(2).items
      end

      it 'should write data to specified file and load game by hash' do
        subject.instance_variable_set :@code, '3456'
        subject.write 'temp.yaml', 'GarrisonD', 'hashcode'

        subject.instance_variable_set :@code, '4321'
        subject.write 'temp.yaml', 'GarrisonD Fake', 'hash code'

        game = Game.read 'temp.yaml', hashcode: 'hashcode'

        code = game.instance_variable_get :@code
        expect(code).to eq '3456'

        nickname = game.instance_variable_get :@nickname
        expect(nickname).to eq 'GarrisonD'

        hashcode = game.instance_variable_get :@hashcode
        expect(hashcode).to eq 'hashcode'
      end
    end
  end
end
