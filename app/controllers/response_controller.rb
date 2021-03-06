require 'log4r'

class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file
  
  # set up logger  
  @@ResponseLogger = Log4r::Logger['responses']
  if @@ResponseLogger.nil?
    # if logger not in config, create new to avoid startup errors.
    @@ResponseLogger = Log4r::Logger.new 'responses'
  end

  # set up logger
  @@ReviewLogger = Log4r::Logger['reviews']
  if @@ReviewLogger.nil?
    #if logger not in config, create new to avoid startup errors.
    @@ReviewLogger = Log4r::Logger.new 'reviews'
  end
  
  def delete
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @user = session[:user]

    map_id = @response.map.id
    @response.delete
    @@ResponseLogger.info("#{@user.name} deleted response with id:#{@response.id} mapped to map_id:#{@response.map_id}.")
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  #Determining the current phase and check if a review is already existing for this stage.
  #If so, edit that version otherwise create a new version.

  def rereview
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @map=ResponseMap.find(params[:id])
     get_content
        array_not_empty=0
      @sorted_array=Array.new
      @prev=Response.all
         #get all versions and find the latest version
      for element in @prev
        if(element.map_id==@map.id)
          array_not_empty=1
          @sorted_array << element
        end
      end

     #sort all the available versions in descending order.
      if array_not_empty==1
         @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
         @largest_version_num=@sorted[0]
         @latest_phase=@largest_version_num.created_at
         due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", @assignment.id])
         @sorted_deadlines=Array.new
         @sorted_deadlines=due_dates.sort {|m1,m2|(m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1)}
         current_time=Time.new.getutc
         #get the highest version numbered review
         next_due_date=@sorted_deadlines[0]

         #check in which phase the latest review was done.
          for deadline_version in @sorted_deadlines
          if(@largest_version_num.created_at < deadline_version.due_at )
            break
          end
         end
         for deadline_time in @sorted_deadlines
           if(current_time < deadline_time.due_at)
             break
           end
         end
      end

         #check if the latest review is done in the current phase.
         #if latest review is in current phase then edit the latest one.
           #else create a new version and update it.

        # editing the latest review
     if(deadline_version.due_at== deadline_time.due_at)
         #send it to edit here
         @header = "Edit"
         @next_action = "update"
         @return = params[:return]
         @response = Response.find_by_map_id_and_version_num(params[:id],@largest_version_num.version_num)
         return if redirect_when_disallowed(@response)
         @modified_object = @response.id
         @map = @response.map
         get_content
         @review_scores = Array.new
         @questions.each{
         | question |
           @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
         }
    #**********************
    # Check whether this is Jen's assgt. & if so, use her rubric
    if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
      if @assignment.id < 469
         @next_action = "custom_update"
         render :action => 'custom_response'
     else
         @next_action = "custom_update"
         render :action => 'custom_response_2011'
     end
    else
      # end of special code (except for the end below, to match the if above)
      #**********************

      render :action => 'response'

    end
           #   render :action => 'edit'
     else
        #else create a new version and update it.

          @header = "New"
          @next_action = "create"
          @feedback = params[:feedback]
          @map = ResponseMap.find(params[:id])
          @return = params[:return]
          @modified_object = @map.id
          get_content
          #**********************
          # Check whether this is Jen's assgt. & if so, use her rubric
          if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
            if @assignment.id < 469
               @next_action = "custom_create"
               render :action => 'custom_response'
           else
               @next_action = "custom_create"
               render :action => 'custom_response_2011'
           end
          else
            # end of special code (except for the end below, to match the if above)
            #**********************
          render :action => 'response'
          end

       end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def edit
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @@ReviewLogger.debug("Entering #{self.class.name}::#{__method__}")
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id]) 
    return if redirect_when_disallowed(@response)
    @map = @response.map 
    array_not_empty=0
    @sorted_array=Array.new
    @prev=Response.all
    for element in @prev
      if(element.map_id==@map.id)
        array_not_empty=1
        @sorted_array << element
      end
    end
    if array_not_empty==1
      @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
      @largest_version_num=@sorted[0]
    end
    @response = Response.find_by_map_id_and_version_num(@map.id,@largest_version_num.version_num)
    @modified_object = @response.id          
    get_content    
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
      @question_type << QuestionType.find_by_question_id(question.id)
    }
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @next_action = "custom_update"
      render :action => 'custom_response'
    else
      # end of special code (except for the end below, to match the if above)
      #**********************
      render :action => 'response'
    end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    @@ReviewLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def redirect_when_disallowed(response)
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment
      team = response.map.reviewer.team
      unless team.has_user session[:user]
        redirect_to '/denied?reason=You are not on the team that wrote this feedback'
        @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
        return true
      end
    else
      @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
      return true unless current_user_id?(response.map.reviewer.user_id)
    end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    return false
  end
  
  def update
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @myid = @response.id
    msg = ""
    begin 
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',params[:review][:comments])
      
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions
     
     
      params[:responses].each_pair do |k,v|
      
        score = Score.find_by_response_id_and_question_id(@response.id, questions[k.to_i].id)
          if(score == nil)
           score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
          end
        score.update_attribute('score',v[:score])
        score.update_attribute('comments',v[:comment])
     end    
    rescue
      msg = "Your response was not saved. Cause: "+ $!
    end

    begin
       ResponseHelper.compare_scores(@response, @questionnaire)
       ScoreCache.update_cache(@response.id)
    
      msg = "Your response was successfully saved."
    rescue
      msg = "An error occurred while saving the response: "+$!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end  
  
  def custom_update
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @response = Response.find(params[:id])
    @myid = @response.id
    msg = ""
    begin
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',"")

      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions

      for i in 0..questions.size-1
        score = Score.find_by_response_id_and_question_id(@response.id, questions[i.to_i].id)
        score.update_attribute('comments',params[:custom_response][i.to_s])
      end
    rescue
      msg = "#{@map.get_title} was not saved."
    end

    msg = "#{@map.get_title} was successfully saved."
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end

  def new_feedback
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    review = Response.find(params[:id])
    @user = session[:user]
    if review
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
      map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
      if map.nil?
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      @@ResponseLogger.info("#{@user.name} is creating #{map.type} for review_id: #{map.id} by reviewer_id: #{map.reviewer_id} for reviewee_id: #{map.reviewee_id}.")
      
      redirect_to :action => 'new', :id => map.id, :return => "feedback"
    else
      redirect_to :back
    end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def view
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @map = @response.map
    get_content
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
      @question_type << QuestionType.find_by_question_id(question.id)
    }
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def new
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @@ReviewLogger.debug("Entering #{self.class.name}::#{__method__}")
    @header = "New"
    @next_action = "create"    
    @feedback = params[:feedback]
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @modified_object = @map.id
    get_content  
    #**********************
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @question_type = Array.new
      @questions.each{
        | question |
        @question_type << QuestionType.find_by_question_id(question.id)
      }
      if !@map.contributor.nil?
        if @map.assignment.team_assignment?
          team_member = TeamsUser.find_by_team_id(@map.contributor).user_id
          @topic_id = Participant.find_by_parent_id_and_user_id(@map.assignment.id,team_member).topic_id
        else
          @topic_id = Participant.find(@map.contributor).topic_id
        end
      end
      if !@topic_id.nil?
        @signedUpTopic = SignUpTopic.find(@topic_id).topic_name
      end
      @next_action = "custom_create"
      render :action => 'custom_response'
    else
      render :action => 'response'
    end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    @@ReviewLogger.debug("Leaving #{self.class.name}::#{__method__}")
   end
  
  def create
    @@ReviewLogger.debug("Entering #{self.class.name}::#{__method__}")
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @map = ResponseMap.find(params[:id])
    @res = 0
    msg = ""
    error_msg = ""
    begin

      #get all previous versions of responses for the response map.
      array_not_empty=0
      @sorted_array=Array.new
      @prev=Response.all
      for element in @prev
        if(element.map_id==@map.id)
          array_not_empty=1
          @sorted_array << element
        end
      end

      #if previous responses exist increment the version number.
      if array_not_empty==1
         @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
         @largest_version_num=@sorted[0]
         if(@largest_version_num.version_num==nil)
            @version=1
         else
            @version=@largest_version_num.version_num+1
         end

        #if no previous version is available then initial version number is 1
      else
          @version=1
      end
      @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:version_num=>@version)
      @res = @response.id
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions     
      params[:responses].each_pair do |k,v|
        score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
      end  
    rescue
      error_msg = "Your response was not saved. Cause: " + $!
    end
    
    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@res)
      @map.save
      msg = "Your response was successfully saved."
    rescue
      @response.delete
      error_msg = "Your response was not saved. Cause: " + $!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg, :error_msg => error_msg
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    @@ReviewLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end      
  
  def custom_create
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @map = ResponseMap.find(params[:id])
    @response = Response.create(:map_id => @map.id, :additional_comment => "")
    @res = @response.id
    @questionnaire = @map.questionnaire
    @user = session[:user]
    questions = @questionnaire.questions
    
    for i in 0..questions.size-1
        # Local variable score is unused; can it be removed?
        score = Score.create(:response_id => @response.id, :question_id => questions[i].id, :score => @questionnaire.max_question_score, :comments => params[:custom_response][i.to_s])
          

    end
    msg = "#{@map.get_title} was successfully saved."
    @@ResponseLogger.info("#{@user.name} created response with id:#{@response.id} mapped to map_id:#{@response.map_id}.")
    
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end

  def saving   
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.notification_accepted = false;
    puts("saving for me ")
    puts(params[:id]);
    @map.save
    @user = session[:user]
    
    @@ResponseLogger.info("#{@user.name} successfully saved #{@map.type} for review_id: #{@map.id} by reviewer_id: #{@map.reviewer_id} for reviewee_id: #{@map.reviewee_id}.")
      
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    redirect_to :action => 'redirection', :id => @map.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
  end
  
  def redirection
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note]  = params[:msg] unless params[:msg] and params[:msg].empty?
    
    @map = ResponseMap.find(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to :controller => 'student_team', :action => 'view', :id => @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id
    end 
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  private
    
  def get_content    
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    @title = @map.get_title 
    @assignment = @map.assignment
    @participant = @map.reviewer
    @contributor = @map.contributor
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def redirect_when_disallowed(response)
    @@ResponseLogger.debug("Entering #{self.class.name}::#{__method__}")
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment
      team = response.map.reviewer.team
      unless team.has_user session[:user]
        redirect_to '/denied?reason=You are not on the team that wrote this feedback'
        @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
        return true
      end
    else
      @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
      return true unless current_user_id?(response.map.reviewer.user_id)
    end
    @@ResponseLogger.debug("Leaving #{self.class.name}::#{__method__}")
    return false
  end
end
