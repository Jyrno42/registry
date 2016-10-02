class RegistrarPresenter
  def initialize(registrar:, view:)
    @registrar = registrar
    @view = view
  end

  def to_s
    registrar.name
  end

  private

  attr_reader :registrar
  attr_reader :view
end
