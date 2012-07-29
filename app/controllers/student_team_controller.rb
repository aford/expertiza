require 'log4r'

class StudentTeamController < ApplicationController
  auto_complete_for :user, :name

  # set up logger
  @@TeamLogger = Log4r::Logger['teams']
  if @@TeamLogger.nil?
    #if logger not in config, create new to avoid startup errors.
    @@TeamLogger = Log4r::Logger.new 'teams'
  end

  def view
    @student = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@student.user_id)
    
    @send_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @student.user.id, @student.assignment.id])
    @received_invs = Invitation.find(:all, :conditions => ['to_id = ? and assignment_id = ? and reply_status = "W"', @student.user.id, @student.assignment.id])
  end
   
  def create
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    @student = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@student.user_id)

    check = AssignmentTeam.find(:all, :conditions => ["name =? and parent_id =?", params[:team][:name], @student.parent_id])        
    @team = AssignmentTeam.new(params[:team])
    @team.parent_id = @student.parent_id    
    #check if the team name is in use
    if (check.length == 0)      
      @team.save
      parent = AssignmentNode.find_by_node_object_id(@student.parent_id)
      TeamNode.create(:parent_id => parent.id, :node_object_id => @team.id)
      user = User.find(@student.user_id)
      @team.add_member(user)
      @@TeamLogger.info("Created team #{@team.name} with user #{user.name}.")
      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    end
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def edit
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    @team = AssignmentTeam.find_by_id(params[:team_id])
    @student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(@student.user_id)
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def update
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    @team = AssignmentTeam.find_by_id(params[:team_id])
    check = AssignmentTeam.find(:all, :conditions => ["name =? and parent_id =?", params[:team][:name], @team.parent_id])    
    if (check.length == 0)
       if @team.update_attributes(params[:team])
          redirect_to :controller => 'student_team', :action => 'view', :id => params[:student_id]
       end
    elsif (check.length == 1 && (check[0].name <=> @team.name) == 0)
      redirect_to :controller => 'student_team', :action => 'view', :id => params[:student_id]
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller =>'student_team', :action => 'edit', :team_id =>params[:team_id], :student_id => params[:student_id]
    end
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def advertise_for_partners
      puts "team #{params[:team_id]}"
      Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
      #respond_to do |format|
      #  format.html #  index.html.erb
      #format.xml  { render :xml => @log_entries }
      #end
      #redirect_to :controller => 'student_team', :action => 'advertise_for_partners' , :id => params[:team_id]
  end
  def remove
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])
    redirect_to :controller => 'student_team', :action => 'view' , :id => params[:team_id]
  end

  def leave
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    @student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(@student.user_id)
    
    #remove the entry from teams_users
    user = TeamsUser.find(:first, :conditions =>["team_id =? and user_id =?", params[:team_id], @student.user_id])
    if user
      user.destroy
    end
    
    #if your old team does not have any members, delete the entry for the team
    other_members = TeamsUser.find(:all, :conditions => ['team_id = ?', params[:team_id]])
    if other_members.length == 0
      old_team = AssignmentTeam.find(:first, :conditions => ['id = ?', params[:team_id]])
      if old_team != nil
        old_team.destroy
        #if assignment has signup sheet then the topic selected by the team has to go back to the pool
        #or to the first team in the waitlist
        signups = SignedUpUser.find(:all, :conditions => {:creator_id => params[:team_id]})
        signups.each {|signup|
          first_waitlisted_user = SignedUpUser.find(:first, :conditions => {:topic_id => signup.topic_id, :is_waitlisted => true})
          if !first_waitlisted_user.nil?
            first_waitlisted_user.is_waitlisted = false
            first_waitlisted_user.save

            user_id = TeamsUser.find(:first, :conditions => {:team_id => first_waitlisted_user.creator_id}).user_id
            participant = Participant.find_by_user_id(user_id)
            participant.update_topic_id(nil)
          end
          signup.destroy
        }
      end
    end
    
    #remove all the sent invitations
    old_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @student.user_id, @student.parent_id])
    for old_inv in old_invs
      old_inv.destroy
    end
    
    #reset the participants submission directory to nil
    #per EFG:
    #the participant is responsible for resubmitting their work
    #no restriction is placed on when a participant can leave
    @student.directory_num = nil
    @student.save
    
    redirect_to :controller => 'student_team', :action => 'view' , :id => @student.id
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def review
    @assignment = Assignment.find_by_id(params[:assignment_id])
    redirect_to :controller =>'questionnaire', :action => 'view_questionnaire', :id => @assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire').id
  end
end
