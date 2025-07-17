# frozen_string_literal: true

# This file is used to configure the genexpert logger
GENEXPERT_LOGGER = Logger.new(Rails.root.join('log/genexpert.log'), 3, 10.megabytes)
GENEXPERT_LOGGER.level = :debug
