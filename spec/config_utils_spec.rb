require_relative '../helpers/config_utils'

RSpec.describe Sinatra::KoreaPI::ConfigUtils do

  CONFIG_FILE_PATH = 'spec/test.properties'

  context 'where no key exists for get_attrs' do

    context 'and properties file is specified' do

      it 'should return nil when key does not exist' do
        result = Sinatra::KoreaPI::ConfigUtils.get_attrs('inexistent_key', 'spec/test.properties')
        expect(result).to be_nil
      end

      it 'should return the correct value when key exists' do
        result = Sinatra::KoreaPI::ConfigUtils.get_attrs('existent_key', 'spec/test.properties')
        expect(result.length).to eq(1)
        expect(result[0]).to eq('existent_value')
      end

    end

    context 'properties file is not specified' do
      it 'should return nil when key does not exist' do
        result = Sinatra::KoreaPI::ConfigUtils.get_attrs('inexistent_key')
        expect(result).to be_nil
      end
    end

  end

  context 'where no key exists for get_first_attr' do

    context 'and properties file is specified' do
      it 'should return nil when nil is specified as default' do
        result = Sinatra::KoreaPI::ConfigUtils.get_first_attr('inexistent_key', nil, 'spec/test.properties')
        expect(result).to be_nil
      end

      it 'should return default value' do
        result = Sinatra::KoreaPI::ConfigUtils.get_first_attr('inexistent_key', 1, 'spec/test.properties')
        expect(result).to eq(1)
      end

      it 'should return the correct value when key exists' do
        result = Sinatra::KoreaPI::ConfigUtils.get_first_attr('existent_key', nil, 'spec/test.properties')
        expect(result).to eq('existent_value')
      end

    end

    context 'and properties file is not specified' do
      it 'should return nil when nil is specified as default' do
        result = Sinatra::KoreaPI::ConfigUtils.get_first_attr('inexistent_key', nil)
        expect(result).to be_nil
      end

      it 'should return default value' do
        result = Sinatra::KoreaPI::ConfigUtils.get_first_attr('inexistent_key', 1)
        expect(result).to eq(1)
      end
    end

  end

end