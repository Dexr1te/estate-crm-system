package com.crm.realestate.repository;

import com.crm.realestate.entity.TaskSeries;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/** Reached only through a task the caller may see; see TaskService. */
@Repository
public interface TaskSeriesRepository extends JpaRepository<TaskSeries, Long> {
}
