require 'rails_helper'

RSpec.describe Vtex::Export::Protheus::Client do
  describe '#phone_area_code' do
    subject(:client) { described_class.new(vtex_client, nil) }

    let(:vtex_client) { Vtex::Client.new(phone: phone) }

    context 'when phone is +5599999078070' do
      let(:phone) { '+5599999078070' }

      it { expect(client.phone_area_code).to eq('99') }
    end

    context 'when phone is +559999772603' do
      let(:phone) { '+559999772603' }

      it { expect(client.phone_area_code).to eq('99') }
    end

    context 'when phone is 2138554183' do
      let(:phone) { '2138554183' }

      it { expect(client.phone_area_code).to eq('21') }
    end

    context 'when phone is 33999937733' do
      let(:phone) { '33999937733' }

      it { expect(client.phone_area_code).to eq('33') }
    end
  end

  describe '#phone_without_area_code' do
    subject(:client) { described_class.new(vtex_client, nil) }

    let(:vtex_client) { Vtex::Client.new(phone: phone) }

    context 'when phone is +5599999078070' do
      let(:phone) { '+5599999078070' }

      it { expect(client.phone_without_area_code).to eq('999078070') }
    end

    context 'when phone is +559999772603' do
      let(:phone) { '+559999772603' }

      it { expect(client.phone_without_area_code).to eq('99772603') }
    end

    context 'when phone is 2138554183' do
      let(:phone) { '2138554183' }

      it { expect(client.phone_without_area_code).to eq('38554183') }
    end

    context 'when phone is 33999937733' do
      let(:phone) { '33999937733' }

      it { expect(client.phone_without_area_code).to eq('999937733') }
    end
  end
end
