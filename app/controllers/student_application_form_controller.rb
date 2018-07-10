require "prawn"

class StudentApplicationFormController < ApplicationController
	before_action :authenticate_user!

	def sap_page
		@sap = current_user.student_application_form
		render "student_application_form/student_application_form"
	end

	def review_step
		user = User.find(params[:user])
		if user.role == "admin"
			redirect_back fallback_location: root_path
		else
			render "student_application_form/review_student_application_form"
		end
	end

	def change_step
		if !params[:step].blank?
			@sap = current_user.student_application_form
			@sap.step = params[:step].to_i
			@sap.save!
		end
		render "student_application_form/student_application_form"
	end

	def save
		@sap = current_user.student_application_form
		@sap.update(params.require(:student_application_form).permit(
				:inst_sending_name, 
				:inst_adress,
				:school_family_dpt,
		  		:erasmus_code,
		  		:dept_coordinator,
		      	:contact_person,
		  		:inst_telephone,
		  		:inst_email,
		  		:languages,
		  		:work_experiences,
		  		:academic_year,
		  		:programme,
		  		:field_of_study,
		  		:project_work,
		  		:under_grad_courses,
		  		:graduate_courses,
		  		:reasons_abroad,
		  		:mother_tongue,
		  		:language_instruction,
		  		:current_diploma_degree,
		  		:year_attended,
		  		:specialization_area,
		  		:already_study_abroad,
		  		:where_study_abroad,
		  		:where_institution_abroad,
			))
		@sap.save!
		render "student_application_form/student_application_form"
	end




	def generate_pdf
		send_data create_pdf(current_user), :filename => "application_form.pdf", :type => "application/pdf"
	end

	private
	def toNumeral(number)
		numeralhash = {1=>"first", 2=>"second", 3=>"third", 4=>"fourth",5=>"fifth",6=>"sixth",7=>"seventh"}
		if numeralhash.has_key?number
			numeralhash[number]
		else
			"first"
		end
	end


	private 
	def create_pdf(user)
	    Prawn::Document.new do
	    	steps = user.student_application_form

	    	# Blue box with logo
	    	def header
	    		fill_color "4664A2"
	    		rectangle [-40, 760], 632, 60
	    		fill
	    		image Rails.root.join("app/assets/images/etsit2.jpg"), :width => 80, :at => [-10, 740]
	    		fill_color "000000"
	    	end

	    	# Section title
	    	def title(field, size = 24)	
	    		move_down 50
	    		fill_color "4664A2"
	    		text ("<b>#{field}</b>"), :inline_format => true, :size => size
	    		move_down 10
	    		fill_color "000000"
	    	end

	    	# Subtitle (user name)
	    	def subtitle(name)
	    		fill_color "777777"
	    		text ("<b>#{name}</b>"), :inline_format => true, :size => 18
	    		fill_color "000000"
	    	end

	    	# Form field label
	    	def label(field)
	    		fill_color "000000"
				text ("<b>#{field}</b>"), :inline_format => true 
				fill_color "000000"
				move_down 2
			end	

			# Form field value
	    	def check_field(field)
	    		fill_color "4664A2"
				text (field.blank? ? "<em>Empty</em>" : field), :inline_format => true 
	    		fill_color "000000"
	    		move_down 10
			end

			# Use Source Sans Pro Font
			font_families.update(
			 "SourceSansPro" => {
			 	:normal => Rails.root.join("app/assets/fonts/SourceSansPro.ttf"),
			 	:bold => Rails.root.join("app/assets/fonts/SourceSansPro-Bold.ttf"),
			 	:italic => Rails.root.join("app/assets/fonts/SourceSansPro-Italic.ttf")
			 }
			)
			font "SourceSansPro"

			# Add header to all pages
			repeat(:all) do
			  header
			end

			# Add page number to all pages
			repeat(:all, :dynamic => true) do
			 draw_text page_number, :at => [530, -10]
			end

			# Cover
			title("Application Form", 32)
			subtitle(user.first_name + " " + user.family_name)
	    	title("Sending Institution")
	    	label("Name")
	    	check_field(steps.inst_sending_name)
	    	label("Erasmus Code")
	    	check_field(steps.erasmus_code)
	    	label("Dept. Coordinator")
	    	check_field(steps.dept_coordinator)
	    	label("School Family Dept")
	    	check_field(steps.school_family_dpt)
	    	label("Institution Address")
	    	check_field(steps.inst_adress)
	    	label("Contact person")
	    	check_field(steps.contact_person)
	    	label("Institution phone")
	    	check_field(steps.inst_telephone)
	    	label("Institution e-mail")
	    	check_field(steps.inst_email)
	    	start_new_page

	    	# Page 2
	    	title("Purpose of stay")
	    	label("Project work")
			check_field(steps.project_work)
	    	label("Under Graduate Courses")
			check_field(steps.under_grad_courses)
	    	label("Graduate Courses")
			check_field(steps.graduate_courses)
			start_new_page

			# Page 3
			title("Study year")
			label("Academic year")
			check_field(steps.academic_year)
			label("Programme")
			check_field(steps.programme)
			label("Field of study")
			check_field(steps.field_of_study)

	    end.render 
	end

end
