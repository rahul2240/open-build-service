require 'rails_helper'

RSpec.describe Webui::AttributeController do
  let!(:user) { create(:confirmed_user) }

  describe 'GET index' do
    it 'shows an error message when package does not exist' do
      get :index, params: { project: user.home_project, package: "Pok" }
      expect(response).to redirect_to(project_show_path(user.home_project))
      expect(flash[:error]).to eq("Package Pok not found")
    end

    it 'shows an error message when project does not exist' do
      get :index, params: { project: "Does:Not:Exist" }
      expect(response).to redirect_to(projects_path)
      expect(flash[:error]).to eq("Project not found: Does:Not:Exist")
    end
  end

  describe 'POST #create' do
    let(:attribute_type_0) { create(:attrib_type_with_namespace, value_count: 0) }
    let(:attribute_type_1) { create(:attrib_type_with_namespace, value_count: 1) }
    let(:attribute_type_1_name) { "#{attribute_type_1.namespace}:#{attribute_type_1.name}" }

    before do
      login user
    end

    context 'with editable values' do
      before do
        post :create, params: { attrib: { project_id: user.home_project.id, attrib_type_id: attribute_type_1.id } }
      end

      it { expect(response).to redirect_to(edit_attribs_path(project: user.home_project_name, package: '', attribute: attribute_type_1_name)) }
      it { expect(flash[:notice]).to eq('Attribute was successfully created.') }
    end

    context 'with non editable values' do
      before do
        post :create, params: { attrib: { project_id: user.home_project.id, attrib_type_id: attribute_type_0.id } }
      end

      it { expect(response).to redirect_to(index_attribs_path(project: user.home_project_name, package: '')) }
      it { expect(flash[:notice]).to eq('Attribute was successfully created.') }
    end

    context 'fails at save' do
      before do
        allow_any_instance_of(Attrib).to receive(:save).and_return(false)
        post :create, params: { attrib: { project_id: user.home_project.id, attrib_type_id: attribute_type_1.id } }
      end

      it { expect(response).to redirect_to(root_path) }
      it { expect(flash[:error]).not_to be_nil }
    end
  end
end
