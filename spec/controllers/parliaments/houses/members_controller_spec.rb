require 'rails_helper'

RSpec.describe Parliaments::Houses::MembersController, vcr: true do

  describe 'GET index' do
    before(:each) do
      get :index, params: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt' }
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    context '@parliament' do
      it 'assigns @parliament' do
        expect(assigns(:parliament)).to be_a(Grom::Node)
        expect(assigns(:parliament).type).to eq('https://id.parliament.uk/schema/ParliamentPeriod')
      end
    end

    context '@house' do
      it 'assigns @house' do
        expect(assigns(:house)).to be_a(Grom::Node)
        expect(assigns(:house).type).to eq('https://id.parliament.uk/schema/House')
      end
    end

    context '@people' do
      it 'assigns @people' do
        assigns(:people).each do |person|
          expect(person).to be_a(Grom::Node)
          expect(person.type).to eq('https://id.parliament.uk/schema/Person')
        end
      end

      it 'assigns @people in alphabetical order' do
        expect(assigns(:people)[0].given_name).to eq('personGivenName - 1')
        expect(assigns(:people)[1].given_name).to eq('personGivenName - 10')
      end
    end

    it 'renders the house template' do
      expect(response).to render_template('index')
    end
  end

  describe 'GET a_to_z' do
    before(:each) do
      get :a_to_z, params: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt' }
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    context '@parliament' do
      it 'assigns @parliament' do
        expect(assigns(:parliament)).to be_a(Grom::Node)
        expect(assigns(:parliament).type).to eq('https://id.parliament.uk/schema/ParliamentPeriod')
      end
    end

    context '@house' do
      it 'assigns @house' do
        expect(assigns(:house)).to be_a(Grom::Node)
        expect(assigns(:house).type).to eq('https://id.parliament.uk/schema/House')
      end
    end

    context '@letters' do
      it 'assigns @letters' do
        expect(assigns(:letters)).to be_a(Array)
      end
    end

    it 'renders the house a-z template' do
      expect(response).to render_template('a_to_z')
    end
  end

  describe 'GET letters' do
    before(:each) do
      get :letters, params: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt', letter: 'd' }
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    context '@parliament' do
      it 'assigns @parliament' do
        expect(assigns(:parliament)).to be_a(Grom::Node)
        expect(assigns(:parliament).type).to eq('https://id.parliament.uk/schema/ParliamentPeriod')
      end
    end

    context '@house' do
      it 'assigns @house' do
        expect(assigns(:house)).to be_a(Grom::Node)
        expect(assigns(:house).type).to eq('https://id.parliament.uk/schema/House')
      end
    end

    context '@people' do
      it 'assigns @people' do
        assigns(:people).each do |person|
          expect(person).to be_a(Grom::Node)
          expect(person.type).to eq('https://id.parliament.uk/schema/Person')
        end
      end

      it 'assigns @people in alphabetical order' do
        expect(assigns(:people)[0].given_name).to eq('personGivenName - 1')
        expect(assigns(:people)[1].given_name).to eq('personGivenName - 10')
      end
    end

    context '@letters' do
      it 'assigns @letters' do
        expect(assigns(:letters)).to be_a(Array)
      end
    end

    it 'renders the house template' do
      expect(response).to render_template('letters')
    end
  end

  describe '#data_check' do
    context 'an available data format is requested' do
      # Currently, a_to_z renders the same data as index, so this is reflected in the api request
      methods = [
          {
            route: 'index',
            parameters: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt' },
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/parliament_house_members?parliament_id=fHx6P1lb&house_id=Kz7ncmrt"
          },
          {
            route: 'a_to_z',
            parameters: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt' },
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/parliament_house_members?parliament_id=fHx6P1lb&house_id=Kz7ncmrt"
          },
          {
            route: 'letters',
            parameters: { parliament_id: 'fHx6P1lb', house_id: 'Kz7ncmrt', letter: 'd' },
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/parliament_house_members_by_initial?parliament_id=fHx6P1lb&house_id=Kz7ncmrt&initial=d"
          }
        ]

      before(:each) do
        headers = { 'Accept' => 'application/rdf+xml' }
        request.headers.merge(headers)
      end

      it 'should have a response with http status redirect (302)' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to have_http_status(302)
        end
      end

      it 'redirects to the data service' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to redirect_to(method[:data_url])
        end
      end

    end
  end
end
