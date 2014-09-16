require 'simple_enum/accessors/multiple_accessor'

module SimpleEnum
  module Accessors
    class JoinTableAccessor < MultipleAccessor
      attr_accessor :table, :foreign_key, :remote_key

      def init(klass)
        table = @table = Arel::Table.new(:"#{klass.table_name}_#{name.pluralize}")

        source = self.source
        name = self.name

        foreign_key = @foreign_key = klass.name.foreign_key
        remote_key = @remote_key = name.singularize.foreign_key

        connection = ActiveRecord::Base.connection

        klass.class_eval do
          attr_accessor source

          define_method :"#{source}_changed?" do
            instance_variable_get(:"@#{source}") !=
              instance_variable_get(:"@#{source}_was")
          end

          define_method :"#{source}_was" do
            instance_variable = instance_variable_get(:"@#{source}_was")
            return instance_variable if instance_variable
            sql = table.where(table[foreign_key].eq(self.id))
              .project(table[remote_key])
              .to_sql
            original_cds = connection.send(:select, sql).rows.map(&:first)
            instance_variable_set(:"@#{source}_was", original_cds)
          end

          define_method source do
            instance_variable = instance_variable_get(:"@#{source}")
            return instance_variable if instance_variable
            instance_variable_set(:"@#{source}", send(:"#{source}_was").dup)
          end

          define_method :"update_#{source}!" do
            return unless send(:"#{source}_changed?")
            original_cds = send(:"#{source}_was")
            current_cds = send(source)

            # if any enum been removed
            if (original_cds - current_cds).any?
              delete_sql = table.where(table[foreign_key].eq(self.id))
                .where(table[remote_key].in(original_cds - current_cds))
                .compile_delete
                .to_sql
              connection.send(:delete, delete_sql)
            end

            # if any enum been added
            # (current_cds - original_cds).each do |id|
            #   insert_sql = table.compile_insert(
            #       table[foreign_key] => self.id, 
            #       table[remote_key] => id
            #     ).to_sql
            #   connection.send(:insert, insert_sql)
            # end
            if (current_cds - original_cds).any?
              insert_sql = table.create_insert.tap do |insert_manager|
                insert_manager.into table
                insert_manager.columns << table[foreign_key]
                insert_manager.columns << table[remote_key]

                values = (current_cds - original_cds).map do |id|
                  "(#{self.id}, #{id})"
                end.join(", ")
                insert_manager.values = Arel::Nodes::SqlLiteral.new("VALUES #{values}")
              end.to_sql
              connection.send(:insert, insert_sql)
            end
          end

          after_save :"update_#{source}!"
        end
      end

      def scope(collection, key, value)
        join = Arel::Nodes::Group.new(table).to_sql
        on = collection.arel_table[collection.primary_key].eq(table[foreign_key]).to_sql
        collection.joins("INNER JOIN #{join} ON #{on}")
          .where(table[foreign_key].eq(value))
      end
    end
  end
end