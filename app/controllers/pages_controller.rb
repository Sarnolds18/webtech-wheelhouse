class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Flat tire repair", price: 8000 },
      { name: "Tube replacement", price: 12000 },
      { name: "Tire replacement", price: 18000 },
      { name: "Brake adjustment", price: 12000 },
      { name: "Brake pad replacement", price: 18000 },
      { name: "Gear adjustment", price: 15000 },
      { name: "Chain replacement", price: 20000 },
      { name: "Chain cleaning and lubrication", price: 10000 },
      { name: "Wheel truing", price: 18000 },
      { name: "Hub adjustment", price: 16000 },
      { name: "Bottom bracket adjustment", price: 20000 },
      { name: "Basic tune-up", price: 30000 },
      { name: "Full tune-up", price: 55000 },
      { name: "Bike assembly", price: 35000 },
      { name: "Safety inspection", price: 10000 }
    ]
  end

  def visiting
  end

  def about
  end
end