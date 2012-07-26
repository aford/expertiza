require 'log4r'

class TeamController < ApplicationController
 auto_complete_for :user, :name

 # set up logger
 @@TeamLogger = Log4r::Logger['teams']
 if @@TeamLogger.nil?
   #if logger not in config, create new to avoid startup errors.
   @@TeamLogger = Log4r::Logger.new 'teams'
 end

def create_teams_view
  @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
 @parent = Object.const_get(session[:team_type]).find(params[:id])
  @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
end

def delete_all
  @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
  parent = Object.const_get(session[:team_type]).find(params[:id])  
  Team.delete_all_by_parent(parent)
  @@TeamLogger.info("All teams deleted with parent_id #{parent.id}.")
  redirect_to :action => 'list', :id => parent.id
  @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
end

def create_teams
  @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
  parent = Object.const_get(session[:team_type]).find(params[:id])
  Team.randomize_all_by_parent(parent, session[:team_type], params[:team][:size].to_i)
  redirect_to :action => 'list', :id => parent.id
  @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end

 def list
   if params[:type]
    session[:team_type] = params[:type]
   end
   @root_node = Object.const_get(session[:team_type] + "Node").find_by_node_object_id(params[:id])
   @child_nodes = @root_node.get_teams()
 end
 
 def new
   @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
   @parent = Object.const_get(session[:team_type]).find(params[:id])
   @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end
 
 def create
   @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
   parent = Object.const_get(session[:team_type]).find(params[:id])
   begin
    Team.check_for_existing(parent, params[:team][:name], session[:team_type])
    team = Object.const_get(session[:team_type]+'Team').create(:name => params[:team][:name], :parent_id => parent.id)
    TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
    @@TeamLogger.info("Team #{team.name} has been created.")
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'new', :id => parent.id
   end
   @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end
 
 def update
   @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
   team = Team.find(params[:id])
   parent = Object.const_get(session[:team_type]).find(team.parent_id)
   begin
    Team.check_for_existing(parent, params[:team][:name], session[:team_type])
    team.name = params[:team][:name]
    team.save
    @@TeamLogger.info("Team #{team.name} has been updated.")
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'edit', :id => team.id
   end
   @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end
 
 def edit
   @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
   @team = Team.find(params[:id])
   @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end
 
 def delete
   @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
   team = Team.find(params[:id])
   course = Object.const_get(session[:team_type]).find(team.parent_id)
   team.delete
   @@TeamLogger.info("Team #{team.name} deleted.")
   redirect_to :action => 'list', :id => course.id
   @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
 end
 
 # Copies existing teams from a course down to an assignment
 # The team and team members are all copied.  
 def inherit
   assignment = Assignment.find(params[:id])
   if assignment.course_id >= 0
    course = Course.find(assignment.course_id)
    teams = course.get_teams
    if teams.length > 0 
      teams.each{
        |team|
        team.copy(assignment.id)
      }
    else
      flash[:note] = "No teams were found to inherit."
    end
   else
     flash[:error] = "No course was found for this assignment."
   end
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id   
 end
 
 # Copies existing teams from an assignment up to a course
 # The team and team members are all copied. 
 def bequeath
   team = AssignmentTeam.find(params[:id])
   assignment = Assignment.find(team.parent_id)
   if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      team.copy(course.id)
      flash[:note] = "\""+team.name+"\" was successfully copied to \""+course.name+"\""
   else
      flash[:error] = "This assignment is not #{url_for(:controller => 'assignment', :action => 'assign', :id => assignment.id)} with a course."
   end      
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id
 end
 
end