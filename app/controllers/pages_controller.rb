class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Flat tire repair", price: 8000, category: "Tires & tubes" },
      { name: "Tube replacement", price: 12000, category: "Tires & tubes" },
      { name: "Tire replacement", price: 18000, category: "Tires & tubes" },
      { name: "Brake adjustment", price: 12000, category: "Brakes" },
      { name: "Brake pad replacement", price: 18000, category: "Brakes" },
      { name: "Gear adjustment", price: 15000, category: "Drivetrain" },
      { name: "Chain replacement", price: 20000, category: "Drivetrain" },
      { name: "Chain cleaning and lubrication", price: 10000, category: "Drivetrain" },
      { name: "Wheel truing", price: 18000, category: "Wheels & bearings" },
      { name: "Hub adjustment", price: 16000, category: "Wheels & bearings" },
      { name: "Bottom bracket adjustment", price: 20000, category: "Wheels & bearings" },
      { name: "Basic tune-up", price: 30000, category: "Full service" },
      { name: "Full tune-up", price: 55000, category: "Full service" },
      { name: "Bike assembly", price: 35000, category: "Full service" },
      { name: "Safety inspection", price: 10000, category: "Full service" }
    ]
  end

  def visiting
  end

  def about
  end
end
