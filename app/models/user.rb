class User
  include Mongoid::Document
  include Amatch

  has_many :recipes do
    def get_pair_distances(query)
      base = PairDistance.new(query)
      results = {}
      self.each do |recipe|
        results[recipe] = base.match(recipe["name"].downcase)
      end
      return results
    end
  end

  field :name, type: String
  field :active_recipe_id, type: BSON::ObjectId
  field :amazon_id, type: String

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  after_create :add_starter_recipe


  def active_recipe
    return nil if self["active_recipe_id"].nil?
    self.recipes.find(self["active_recipe_id"])
  end

  protected

  def add_starter_recipe
    recipe = self.recipes.new(
      name: "Ice Cream Sundae",
      description: "This sundae is classic, colorful, and super easy to make. Try out this recipe with Alexa Recipes on your Echo device!",
      prep_time: "3 minutes",
      servings: 1,
      ingredients: [
        {
          "name"=>"vanilla ice-cream",
          "measurement"=>"2",
          "unit"=>"scoops"
        },
        {
          "name"=>"banana",
          "measurement"=>"1",
          "unit"=>nil
        },
        {
          "name"=>"chopped nuts",
          "measurement"=>"2",
          "unit"=>"tablespoons"
        },
        {
          "name"=>"strawberry syrup",
          "measurement"=>"1",
          "unit"=>"good squeeze"
        },
        {
          "name"=>"maraschino cherries",
          "measurement"=>"3",
          "unit"=>nil
        },
        {
          "name"=>"whipped cream",
          "measurement"=>"1",
          "unit"=>"dollop"
        },
        {
          "name"=>"sprinkles",
          "measurement"=>nil,
          "unit"=>nil
        }
      ],
      steps: [
        "Split the banana in half lengthwise and place in dish.",
        "Add scoops of ice-cream between the banana slices.",
        "Top with nuts, syrup, and whipped cream.",
        "Add cherries and finish with a generous helping of sprinkles."
      ],
    )
    recipe.save
  end
end
